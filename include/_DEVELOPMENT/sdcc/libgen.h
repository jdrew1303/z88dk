
// automatically generated by m4 from headers in proto subdir


#ifndef __LIBGEN_H__
#define __LIBGEN_H__

extern char *basename(char *path);
extern char *basename_fastcall(char *path) __z88dk_fastcall;
#define basename(a) basename_fastcall(a)


extern char *basename_ext(char *path);
extern char *basename_ext_fastcall(char *path) __z88dk_fastcall;
#define basename_ext(a) basename_ext_fastcall(a)


extern char *dirname(char *path);
extern char *dirname_fastcall(char *path) __z88dk_fastcall;
#define dirname(a) dirname_fastcall(a)


extern char *pathnice(char *path);
extern char *pathnice_fastcall(char *path) __z88dk_fastcall;
#define pathnice(a) pathnice_fastcall(a)



#endif
