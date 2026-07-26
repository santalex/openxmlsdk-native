using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Presentation;
using DocumentFormat.OpenXml.Wordprocessing;

namespace OpenXmlSdk.Native
{
    public static class NativeExports
    {
        [UnmanagedCallersOnly(EntryPoint = "openxml_native_version")]
        public static int Version()
        {
            return 100;
        }

        [UnmanagedCallersOnly(EntryPoint = "openxml_native_get_info")]
        public static unsafe int GetInfo(IntPtr outBufferPtr, int bufferSize)
        {
            try
            {
                var asm = typeof(PresentationDocument).Assembly;
                var versionStr = asm.GetName().Version?.ToString() ?? "Unknown";
                var netVersion = RuntimeInformation.FrameworkDescription;
                string info = $"DocumentFormat.OpenXml: {versionStr} | Runtime: {netVersion}";

                byte[] bytes = Encoding.UTF8.GetBytes(info + "\0");
                int lengthToCopy = Math.Min(bytes.Length, bufferSize - 1);
                Marshal.Copy(bytes, 0, outBufferPtr, lengthToCopy);
                return 0;
            }
            catch (Exception ex)
            {
                string errInfo = $"Error: {ex.Message}";
                byte[] bytes = Encoding.UTF8.GetBytes(errInfo + "\0");
                int lengthToCopy = Math.Min(bytes.Length, bufferSize - 1);
                Marshal.Copy(bytes, 0, outBufferPtr, lengthToCopy);
                return -1;
            }
        }

        [UnmanagedCallersOnly(EntryPoint = "openxml_inspect_pptx")]
        public static unsafe int InspectPptx(IntPtr filePathPtr, IntPtr outBufferPtr, int bufferSize)
        {
            try
            {
                if (filePathPtr == IntPtr.Zero || outBufferPtr == IntPtr.Zero) return -1;
                string? filePath = Marshal.PtrToStringUTF8(filePathPtr);
                if (string.IsNullOrEmpty(filePath) || !File.Exists(filePath)) return -2;

                using (PresentationDocument ppt = PresentationDocument.Open(filePath, isEditable: false))
                {
                    var presentationPart = ppt.PresentationPart;
                    if (presentationPart == null || presentationPart.Presentation == null) return -3;

                    int slideCount = presentationPart.SlideParts != null ? System.Linq.Enumerable.Count(presentationPart.SlideParts) : 0;
                    string info = $"Success: Parsed PPTX. Total Slides: {slideCount}";

                    byte[] bytes = Encoding.UTF8.GetBytes(info + "\0");
                    int lengthToCopy = Math.Min(bytes.Length, bufferSize - 1);
                    Marshal.Copy(bytes, 0, outBufferPtr, lengthToCopy);
                    return slideCount;
                }
            }
            catch (Exception ex)
            {
                string errInfo = $"Error: {ex.Message}";
                byte[] bytes = Encoding.UTF8.GetBytes(errInfo + "\0");
                int lengthToCopy = Math.Min(bytes.Length, bufferSize - 1);
                Marshal.Copy(bytes, 0, outBufferPtr, lengthToCopy);
                return -99;
            }
        }
    }
}
