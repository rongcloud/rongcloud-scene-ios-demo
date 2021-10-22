#ifndef SG_C_C_API_H_
#define SG_C_C_API_H_

#include <stdint.h>

#if defined(_WIN32)
#ifdef SG_BUILD_SHARED_LIB
#define SG_CAPI_EXPORT __declspec(dllexport)
#else
#define SG_CAPI_EXPORT
#endif
#else
#define SG_CAPI_EXPORT __attribute__((visibility("default")))
#endif  // _WIN32

#ifdef __cplusplus
extern "C" {
#endif

typedef enum StreamFormat {
  STREAM_RGB = 0,
  STREAM_BGR = 1,
  STREAM_RGBA = 2,
  STREAM_BGRA = 3,
  STREAM_YUV_NV12 = 4,
  STREAM_YUV_NV21 = 5,
} StreamFormat;


typedef enum CameraRotation {
  CAMERA_ROTATION_0 = 0,
  CAMERA_ROTATION_90  = 1,
  CAMERA_ROTATION_180 = 2,
  CAMERA_ROTATION_270 = 3,
} CameraRotation;

typedef struct SG_CameraStream SG_CameraStream;

SG_CAPI_EXPORT extern SG_CameraStream* SG_CreateCameraStream();
SG_CAPI_EXPORT extern void SG_ReleaseCameraStream(SG_CameraStream* camera_stream);
SG_CAPI_EXPORT extern void SG_CameraStreamSetData(SG_CameraStream* camerat_stream,const uint8_t* data,int width,int height);
SG_CAPI_EXPORT extern void SG_CameraStreamSetRotationMode(SG_CameraStream* image_view, CameraRotation mode);
SG_CAPI_EXPORT extern void SG_CameraStreamSetStreamFormat(SG_CameraStream* image_view, StreamFormat mode);

typedef struct SG_LandmarkTracker SG_LandmarkTracker;
//typedef struct SG_FaceRecognition SG_FaceRecognition;

SG_CAPI_EXPORT extern SG_LandmarkTracker* SG_CreateLandmarkTracker(const char *path_model);

SG_CAPI_EXPORT extern int SG_LandmarkTrackerGetStatus(
    SG_LandmarkTracker* tracker);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerProcessFrame(
    SG_LandmarkTracker* tracker, SG_CameraStream* camera_stream);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerSetSmoothRatio(
    SG_LandmarkTracker* model, float ratio);

SG_CAPI_EXPORT extern void SG_ReleaseLandmarkTracker(
    SG_LandmarkTracker* model);

SG_CAPI_EXPORT extern int SG_LandmarkTrackerGetFaceNum(
        SG_LandmarkTracker* model);

SG_CAPI_EXPORT extern int SG_LandmarkTrackerGetLandmarkNum(
        SG_LandmarkTracker* model);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerGetInfoLandmarks(
    SG_LandmarkTracker* model, int index,float* landmark);

SG_CAPI_EXPORT extern int SG_LandmarkTrackerGetInfoTrackId(
    SG_LandmarkTracker* model, int index);

SG_CAPI_EXPORT extern float SG_LandmarkTrackerGetInfoScore(
    SG_LandmarkTracker* model, int index);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerGetInfoEulerAngle(
    SG_LandmarkTracker* model, int index , float *euler_angle,int size);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerGetFaceAction( SG_LandmarkTracker* model, int index , int *is_blink , int *is_shake,int *is_mouth_open , int *head_rise);

SG_CAPI_EXPORT extern void SG_LandmarkTrackerSetFaceDetectionScale(
    SG_LandmarkTracker* model,  float scale);

SG_CAPI_EXPORT extern int SG_LandmarkTrackerSetupLicense(
    char* lic_bitcode,int lic_size);


//SG_CAPI_EXPORT extern SG_FaceRecognition* SG_CreateFaceRecognition(const char *path_model);

#ifdef __cplusplus
}
#endif

#endif  // SG_C_C_API_H_
