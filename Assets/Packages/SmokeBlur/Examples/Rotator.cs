using UnityEngine;
using System.Collections;

namespace SmokeBlurSystem {

	public class Rotator : MonoBehaviour {
		public const float SEED = 1000f;

		public float speed = 1f;
		public float freq = 0.1f;

		Vector3 _seed;

		void Start() {
			_seed = new Vector3 (Random.Range (-SEED, SEED), Random.Range (-SEED, SEED), Random.Range (-SEED, SEED));
		}
		void Update () {
			var t = Time.timeSinceLevelLoad * freq;
			var dt = Time.deltaTime * speed;
			transform.localRotation *= Quaternion.Euler (
				dt * Noise (t + _seed.x, _seed.y),
				dt * Noise (t + _seed.y, _seed.z),
				dt * Noise (t + _seed.z, _seed.x));
		}
		float Noise(float x, float y) { return 2f * Mathf.PerlinNoise(x, y) - 1f; }
	}
}