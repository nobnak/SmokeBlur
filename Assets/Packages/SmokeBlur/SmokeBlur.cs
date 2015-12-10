using UnityEngine;
using System.Collections;

namespace SmokeBlurSystem {

	[RequireComponent(typeof(Camera))]
	public class SmokeBlur : MonoBehaviour {
		public const string PROP_ACCUM = "_Accum";
		public const string PROP_ATTEN = "_Atten";
		public const string PROP_BLUR_MAT = "_BlurMat";

		public const int PASS_ACCUM = 0;
		public const int PASS_BLUR = 1;
		public const int PASS_ATTEN = 2;

		public Shader shader;

		public float accum = 0.01f;
		public float atten = 0.01f;
		public float blurSigma = 0.85f;
		public int blurIter = 1;

		Material _mat;
		Matrix4x4 _blurMat;
		RenderTexture _blurTex0, _blurTex1;

		void Start() {
			_mat = new Material(shader);
		}
		void OnDestroy() {
			Destroy(_mat);
			ReleaseTex();
		}
		void Update() {
			accum = Mathf.Clamp01(accum);
			atten = Mathf.Clamp01(atten);
			blurSigma = Mathf.Clamp01(blurSigma);
			blurIter = Mathf.Clamp(blurIter, 1, 10);

			var coeff = -1f / (2f * blurSigma * blurSigma);
			var f11 = 1f;
			var f12 = Mathf.Exp(coeff);
			var f22 = Mathf.Exp(2f * coeff);
			var invSum = 1f / (f11 + 4 * f12 + 4 * f22);
			_blurMat[1, 1] = invSum * f11;
			_blurMat[0, 1] = _blurMat[1, 0] = _blurMat[2, 1] = _blurMat[1, 2] = invSum * f12;
			_blurMat[0, 0] = _blurMat[2, 0] = _blurMat[0, 2] = _blurMat[2, 2] = invSum * f22;
		}
		void OnRenderImage(RenderTexture src, RenderTexture dst) {
			if (_blurTex0 == null || _blurTex0.width != src.width || _blurTex0.height != src.height) {
				ReleaseTex();
				_blurTex0 = CreateTex(src.width, src.height);
				_blurTex1 = CreateTex(src.width, src.height);
			}
			_mat.SetFloat(PROP_ACCUM, accum);
			_mat.SetFloat(PROP_ATTEN, atten);
			_mat.SetMatrix(PROP_BLUR_MAT, _blurMat);
			Graphics.Blit(src, _blurTex0, _mat, PASS_ACCUM);

			for (var i = 0; i < blurIter; i++) {
				Graphics.Blit(_blurTex0, _blurTex1, _mat, PASS_BLUR);
				SwapTex();
			}

			Graphics.Blit(_blurTex0, _blurTex1, _mat, PASS_ATTEN);
			Graphics.Blit(_blurTex1, dst);
			SwapTex();
		}

		void ReleaseTex() {
			Destroy(_blurTex0);
		}

		void SwapTex() {
			var tmpTex = _blurTex0;
			_blurTex0 = _blurTex1;
			_blurTex1 = tmpTex;
		}

		static RenderTexture CreateTex (int width, int height) {
			var _blurTex = new RenderTexture (width, height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
			_blurTex.wrapMode = TextureWrapMode.Clamp;
			_blurTex.filterMode = FilterMode.Bilinear;
			_blurTex.antiAliasing = (QualitySettings.antiAliasing == 0 ? 1 : QualitySettings.antiAliasing);
			_blurTex.Create ();
			return _blurTex;
		}
	}
}