#ifndef __DEPTH_CGINC__
#define __DEPTH_CGINC__

float Z2EyeDepth(float z) {
    return unity_OrthoParams.w < 0.5
        ? LinearEyeDepth(z)
        : ((_ProjectionParams.z - _ProjectionParams.y) * z + _ProjectionParams.y);
}

#endif
