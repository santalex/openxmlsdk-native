#ifndef OpenXmlSdkNative_h
#define OpenXmlSdkNative_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * 获取 OpenXmlSdkNative FFI API 契约版本号
 * @return 契约版本号 (如 100)
 */
int32_t openxml_native_version(void);

/**
 * 获取 DocumentFormat.OpenXml 官方 NuGet 包描述与 .NET Runtime 运行时版本
 * @param outBuffer 输出缓冲区指针
 * @param bufferSize 缓冲区字节大小
 * @return 0 成功, 非 0 失败
 */
int32_t openxml_native_get_info(char *outBuffer, int32_t bufferSize);

#ifdef __cplusplus
}
#endif

#endif /* OpenXmlSdkNative_h */
