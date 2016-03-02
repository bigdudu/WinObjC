//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#include "Starboard.h"

#include "CGImageInternal.h"
#include "CGContextInternal.h"
#include "AudioToolbox/AudioToolbox.h"
#include "AVFoundation/AVAudioPlayer.h"
#include "Social/SLServiceTypes.h"
#include "objc/runtime.h"
#include <CommonCrypto/CommonDigest.h>
#include <inttypes.h>
#include <mach/mach.h>
#include <dispatch/dispatch.h>
#include <mutex>
#include <random>

typedef unsigned int mach_port_t;

EbrEvent _applicationStateChanged;
int g_browsersVisible = 0;
UIDeviceOrientation newDeviceOrientation = UIDeviceOrientationUnknown;

static std::mutex s_rngGuard;
static std::mt19937 s_rng;

@interface UIKeyboardRotationView : UIView
@end

@implementation UIKeyboardRotationView
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView* ret = [super hitTest:point withEvent:event];

    if (ret == self)
        return nil;

    return ret;
}
@end

@implementation _UISettings
@end

@implementation UIAppearanceSetter
+ (void)_applyAppearance:(UIView*)view {
}
+ (void)_applyAppearance:(UIView*)view withAppearanceClass:(Class)cls withBaseView:(UIView*)baseView {
}
@end

__declspec(dllexport) extern "C" unsigned random() {
    std::lock_guard<std::mutex> lock(s_rngGuard);

    //  The expected range for random() is a value 0->0x7fffffff
    return (s_rng() >> 1);
}

__declspec(dllexport) extern "C" int gettimeofday(struct timeval* tv, void* restrict) {
    EbrTimeval curtime;
    EbrGetTimeOfDay(&curtime);
    tv->tv_sec = curtime.tv_sec;
    tv->tv_usec = curtime.tv_usec;
    return 0;
}

__declspec(dllexport) extern "C" void srandom(unsigned val) {
    std::lock_guard<std::mutex> lock(s_rngGuard);
    s_rng.seed(val);
}

/**
@Status Stub
*/
__declspec(dllexport) extern "C" mach_port_t mach_host_self(void) {
    UNIMPLEMENTED();
    return (mach_port_t)0xBAADF00D;
}

int vm_page_size = 65536;

/**
@Status Stub
*/
__declspec(dllexport) extern "C" int host_statistics(mach_port_t port, int type, host_info_t dataOut, mach_msg_type_number_t* dataOutSize) {
    if (type == HOST_VM_INFO && *dataOutSize >= sizeof(vm_statistics)) {
        *dataOutSize = sizeof(vm_statistics);

        vm_statistics* ret = (vm_statistics*)dataOut;
        memset(ret, 0, sizeof(vm_statistics));

        ret->free_count = 512 * 1024 * 1024 / 65536;
    } else {
        UNIMPLEMENTED();
    }

    return 0;
}

/**
@Status Stub
*/
__declspec(dllexport) extern "C" const char* strnstr(const char* a, const char* b, int len) {
    UNIMPLEMENTED();
    return NULL;
}

EbrPlatformInfo* EbrGetDeviceInfo() {
    static EbrPlatformInfo info;
    static bool infoInited = false;

    if (!infoInited) {
        infoInited = true;

        info.platformName = "Windows 10";
        info.manufacturer = "Microsoft";
        info.model = "Desktop PC";
        info.deviceProductName = "Computer";
        info.serialNo = "12345";
        info.carrier = "Versalife, Inc";
        info.osVersion = "10.0";
        info.osVersionInt = 10;
        info.deviceResX = 788;
        info.deviceResY = 866;
        info.devicePhysWidth = 2.7f;
        info.devicePhysHeight = 5.f;
    }

    return &info;
}

@implementation CBCentralManager
@end

@implementation GCDAsyncSocket
@end

typedef void* DNSServiceRef;
typedef unsigned DNSServiceErrorType;
typedef unsigned DNSServiceFlags;
typedef unsigned DNSServiceProtocol;
typedef void (*DNSServiceBrowseReply)(DNSServiceRef sdRef,
                                      DNSServiceFlags flags,
                                      unsigned interfaceIndex,
                                      DNSServiceErrorType errorCode,
                                      const char* serviceName,
                                      const char* regtype,
                                      const char* replyDomain,
                                      void* context);
typedef void (*DNSServiceResolveReply)(DNSServiceRef sdRef,
                                       DNSServiceFlags flags,
                                       uint32_t interfaceIndex,
                                       DNSServiceErrorType errorCode,
                                       const char* fullname,
                                       const char* hosttarget,
                                       uint16_t port,
                                       /* In network byte order */ uint16_t txtLen,
                                       const unsigned char* txtRecord,
                                       void* context);
typedef void (*DNSServiceGetAddrInfoReply)(DNSServiceRef sdRef,
                                           DNSServiceFlags flags,
                                           uint32_t interfaceIndex,
                                           DNSServiceErrorType errorCode,
                                           const char* hostname,
                                           const struct sockaddr* address,
                                           uint32_t ttl,
                                           void* context);
typedef void (*DNSServiceRegisterReply)(DNSServiceRef sdRef,
                                        DNSServiceFlags flags,
                                        DNSServiceErrorType errorCode,
                                        const char* name,
                                        const char* regtype,
                                        const char* domain,
                                        void* context);

UIKIT_EXPORT
extern "C" void DNSServiceRefDeallocate(DNSServiceRef sdRef) {
    [sdRef dealloc];
}

UIKIT_EXPORT
extern "C" DNSServiceErrorType DNSServiceSetDispatchQueue(DNSServiceRef service, dispatch_queue_t queue) {
    UNIMPLEMENTED_WITH_MSG("DNSServiceSetDispatchQueue");
    return 0;
}

UIKIT_EXPORT
extern "C" DNSServiceErrorType DNSServiceBrowse(DNSServiceRef* sdRef,
                                                DNSServiceFlags flags,
                                                uint32_t interfaceIndex,
                                                const char* regtype,
                                                const char* domain,
                                                /* may be NULL */ DNSServiceBrowseReply callBack,
                                                void* context /* may be NULL */) {
    UNIMPLEMENTED_WITH_MSG("DNSServiceBrowse");
    return 0;
}

UIKIT_EXPORT
extern "C" DNSServiceErrorType DNSServiceGetAddrInfo(DNSServiceRef* sdRef,
                                                     DNSServiceFlags flags,
                                                     uint32_t interfaceIndex,
                                                     DNSServiceProtocol protocol,
                                                     const char* hostname,
                                                     DNSServiceGetAddrInfoReply callBack,
                                                     void* context /* may be NULL */) {
    UNIMPLEMENTED_WITH_MSG("DNSServiceGetAddrInfo");
    return 0;
}

UIKIT_EXPORT
extern "C" DNSServiceErrorType DNSServiceResolve(DNSServiceRef* sdRef,
                                                 DNSServiceFlags flags,
                                                 uint32_t interfaceIndex,
                                                 const char* name,
                                                 const char* regtype,
                                                 const char* domain,
                                                 DNSServiceResolveReply callBack,
                                                 void* context /* may be NULL */) {
    UNIMPLEMENTED_WITH_MSG("DNSServiceResolve");
    return 0;
}

@interface NSFont : NSObject
@end

@implementation NSFont
@end

#include <Windows.h>
#include <inaddr.h>

UIKIT_EXPORT extern "C" char* __inet_ntoa(struct in_addr addr) {
    UNIMPLEMENTED_WITH_MSG("__inet_ntoa");
    return 0;
}

UIKIT_EXPORT extern "C" char* if_indextoname(unsigned int ifindex, char* ifname) {
    UNIMPLEMENTED_WITH_MSG("if_indextoname");
    return 0;
}

UIKIT_EXPORT extern "C" DNSServiceErrorType DNSServiceRegister(DNSServiceRef* sdRef,
                                                               DNSServiceFlags flags,
                                                               uint32_t interfaceIndex,
                                                               const char* name,
                                                               /* may be NULL */ const char* regtype,
                                                               const char* domain,
                                                               /* may be NULL */ const char* host,
                                                               /* may be NULL */ uint16_t port,
                                                               /* In network byte order */ uint16_t txtLen,
                                                               const void* txtRecord,
                                                               /* may be NULL */ DNSServiceRegisterReply callBack,
                                                               /* may be NULL */ void* context /* may be NULL */) {
    UNIMPLEMENTED_WITH_MSG("DNSServiceRegister");
    return 0;
}