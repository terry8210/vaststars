#include <lua.hpp>
#include <string>
#include "core/world.h"

#if defined(_MSC_VER)
#include <windows.h>
static std::wstring u2w(const std::string_view& str) {
    if (str.empty())  {
        return L"";
    }
    int wlen = ::MultiByteToWideChar(CP_UTF8, 0, str.data(), (int)str.size(), NULL, 0);
    if (wlen <= 0)  {
        return L"";
    }
    std::vector<wchar_t> result(wlen);
    ::MultiByteToWideChar(CP_UTF8, 0, str.data(), (int)str.size(), result.data(), wlen);
    return std::wstring(result.data(), result.size());
}
#endif

template <typename T>
void file_write(FILE* f, const T& v) {
    size_t n = fwrite(&v, sizeof(T), 1, f);
    assert(n == 1);
}

template <typename T>
T file_read(FILE* f) {
    T v;
    size_t n = fread(&v, sizeof(T), 1, f);
    assert(n == 1);
    return std::move(v);
}

template <typename T>
void file_read(FILE* f, T& v) {
    size_t n = fread(&v, sizeof(T), 1, f);
    assert(n == 1);
}

template <typename T>
void file_write(FILE* f, const T* v, size_t sz) {
    if (sz == 0) {
        return;
    }
    size_t n = fwrite(v, sizeof(T), sz, f);
    assert(n == sz);
}

template <typename T>
void file_read(FILE* f, T* v, size_t sz) {
    if (sz == 0) {
        return;
    }
    size_t n = fread(v, sizeof(T), sz, f);
    assert(n == sz);
}

enum class filemode {
    read,
    write,
};

static FILE* createfile(lua_State* L, int idx, const char* filename, filemode mode) {
    size_t sz = 0;
    const char* dir = luaL_checklstring(L, idx, &sz);
    std::string path = std::string(dir, sz) + "/" + filename;
#if defined(_MSC_VER)
    FILE* f = NULL;
    errno_t err = _wfopen_s(&f, u2w(path).c_str(), mode == filemode::read? L"rb": L"wb");
    if (err != 0 || !f) {
        if (!f) {
            fclose(f);
        }
        luaL_error(L, "open file `%s` failed.", path.c_str());
    }
#else
    FILE* f = fopen(path.c_str(), mode == filemode::read? "r": "w");
    if (!f) {
        luaL_error(L, "open file `%s` failed.", path.c_str());
    }
#endif
    return f;
}

template <typename Map>
struct mapdata {
    struct {
        size_t mask;
        size_t maxsize;
        size_t size;
    } h;
    typename Map::bucket* buckets;
};

template <typename Map>
static void write_flatmap(FILE* f, const Map& map) {
    const mapdata<Map>& data = reinterpret_cast<const mapdata<Map>&>(map);
    file_write(f, data.h);
    if (data.h.mask !=0 ) {
        file_write(f, data.buckets, data.h.size);
    }
}

template <typename Map>
static void read_flatmap(FILE* f, Map& map) {
    mapdata<Map>& data = reinterpret_cast<mapdata<Map>&>(map);
    if (data.h.mask != 0) {
        std::free(data.buckets);
    }
    file_read(f, data.h);
    if (data.h.mask == 0) {
        data.buckets = reinterpret_cast<decltype(data.buckets)>(&data.h.mask);
    }
    else {
        data.buckets = static_cast<decltype(data.buckets)>(std::malloc(sizeof(data.buckets[0]) * data.h.size));
        if (!data.buckets) {
            throw std::bad_alloc {};
        }
        file_read(f, data.buckets, data.h.size);
    }
}

template <typename Vec>
static void write_vector(FILE* f, const Vec& vec) {
    file_write(f, vec.size());
    file_write(f, vec.data(), vec.size());
}

template <typename Vec>
static void read_vector(FILE* f, Vec& vec) {
    size_t n = 0;
    file_read(f, n);
    vec.resize(n);
    file_read(f, vec.data(), vec.size());
}

namespace sav_container {
    struct header {
        uint16_t chest_size;
        uint16_t recipe_size;
    };

    struct chest_header {
        uint16_t slot_size;
        uint16_t used;
        uint16_t size;
    };

    struct recipe_header {
        uint16_t in_size;
        uint16_t out_size;
    };

    static void backup(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "container.bin", filemode::write);
        header h {
            (uint16_t)w.containers.chest.size(),
            (uint16_t)w.containers.recipe.size(),
        };
        file_write(f, h);
        for (auto const& c : w.containers.chest) {
            chest_header chest_h {
                (uint16_t)c.slots.size(),
                c.used,
                c.size,
            };
            file_write(f, chest_h);
            file_write(f, c.slots.data(), c.slots.size());
        }
        for (auto const& c : w.containers.recipe) {
            recipe_header recipe_h {
                (uint16_t)c.inslots.size(),
                (uint16_t)c.outslots.size(),
            };
            file_write(f, recipe_h);
            file_write(f, c.inslots.data(), c.inslots.size());
            file_write(f, c.outslots.data(), c.outslots.size());
        }
        fclose(f);
    }

    static void restore(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "container.bin", filemode::read);
        auto h = file_read<header>(f);
        w.containers.chest.resize(h.chest_size);
        w.containers.recipe.resize(h.recipe_size);
        for (auto& c : w.containers.chest) {
            auto chest_h = file_read<chest_header>(f);
            c.slots.resize(chest_h.slot_size);
            c.used = chest_h.used;
            c.size = chest_h.size;
            file_read(f, c.slots.data(), c.slots.size());
        }
        for (auto& c : w.containers.recipe) {
            auto recipe_h = file_read<recipe_header>(f);
            c.inslots.resize(recipe_h.in_size);
            c.outslots.resize(recipe_h.out_size);
            file_read(f, c.inslots.data(), c.inslots.size());
            file_read(f, c.outslots.data(), c.outslots.size());
        }
        fclose(f);
    }
}

namespace sav_statistics {
    static void backup(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "statistics.bin", filemode::write);
        write_flatmap(f, w.stat.production);
        write_flatmap(f, w.stat.consumption);
        fclose(f);
    }
    static void restore(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "statistics.bin", filemode::read);
        read_flatmap(f, w.stat.production);
        read_flatmap(f, w.stat.consumption);
        fclose(f);
    }
}

namespace sav_techtree {
    static void backup(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "techtree.bin", filemode::write);
        write_vector(f, w.techtree.queue);
        write_flatmap(f, w.techtree.researched);
        write_flatmap(f, w.techtree.progress);
        fclose(f);
    }
    static void restore(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "techtree.bin", filemode::read);
        read_vector(f, w.techtree.queue);
        read_flatmap(f, w.techtree.researched);
        read_flatmap(f, w.techtree.progress);
        fclose(f);
    }
}

static int
lbackup(lua_State* L) {
    world& w = *(world*)lua_touserdata(L, 1);
    sav_container::backup(L, w);
    sav_statistics::backup(L, w);
    sav_techtree::backup(L, w);
    return 0;
}

static int
lrestore(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    sav_container::restore(L, w);
    sav_statistics::restore(L, w);
    sav_techtree::restore(L, w);
    return 0;
}

extern "C" int
luaopen_vaststars_saveload_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "backup", lbackup },
		{ "restore", lrestore },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
