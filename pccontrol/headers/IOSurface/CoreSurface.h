#ifndef CORESURFACE_H
#define CORESURFACE_H

#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void * CoreSurfaceBufferRef;
typedef void * CoreSurfaceAcceleratorRef;

/* Keys for the CoreSurfaceBufferCreate dictionary. */
extern CFStringRef kCoreSurfaceBufferGlobal;        /* CFBoolean */
extern CFStringRef kCoreSurfaceBufferMemoryRegion;  /* CFStringRef */
extern CFStringRef kCoreSurfaceBufferPitch;         /* CFNumberRef */
extern CFStringRef kCoreSurfaceBufferWidth;         /* CFNumberRef */
extern CFStringRef kCoreSurfaceBufferHeight;        /* CFNumberRef */
extern CFStringRef kCoreSurfaceBufferPixelFormat;   /* CFNumberRef (fourCC) */
extern CFStringRef kCoreSurfaceBufferAllocSize;     /* CFNumberRef */
extern CFStringRef kCoreSurfaceBufferClientAddress; /* CFNumberRef */

CoreSurfaceBufferRef CoreSurfaceBufferCreate(CFDictionaryRef dict);
unsigned int CoreSurfaceBufferGetPixelFormatType(CoreSurfaceBufferRef surface);
unsigned int CoreSurfaceBufferGetID(CoreSurfaceBufferRef surface);
unsigned int CoreSurfaceBufferGetPlaneCount(CoreSurfaceBufferRef surface);

int CoreSurfaceBufferLock(CoreSurfaceBufferRef surface, int unknown);
int CoreSurfaceBufferUnlock(CoreSurfaceBufferRef surface);
int CoreSurfaceBufferWrapClientMemory(CoreSurfaceBufferRef surface);
void *CoreSurfaceBufferGetBaseAddress(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetAllocSize(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetWidth(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetHeight(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetBytesPerRow(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetBytesPerElement(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetElementWidth(CoreSurfaceBufferRef surface);
size_t CoreSurfaceBufferGetElementHeight(CoreSurfaceBufferRef surface);

/* Set type to 0. */
int CoreSurfaceAcceleratorCreate(CFAllocatorRef allocator, int type,
    CoreSurfaceAcceleratorRef *accel);
unsigned int CoreSurfaceAcceleratorTransferSurfaceWithSwap(
    CoreSurfaceAcceleratorRef accelerator, CoreSurfaceBufferRef dest,
    CoreSurfaceBufferRef src, CFDictionaryRef options);

#ifdef __cplusplus
}
#endif

#endif

