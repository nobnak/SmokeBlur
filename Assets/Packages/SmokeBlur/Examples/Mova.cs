using UnityEngine;
using System.Collections;

namespace SmokeBlurSystem {

	public class Mova : MonoBehaviour {
		public const string PROP_COLOR = "_Color";

		public GameObject cubefab;
		public int count = 100;
		public float radius = 5f;
		public float size = 0.2f;
		public Color baseColor = Color.white;

		void Start() {
			for (var i = 0; i < count; i++) {
				var c = Instantiate(cubefab);

				var tr = c.transform;
				tr.localPosition = radius * Random.insideUnitSphere;
				tr.localRotation = Random.rotationUniform;
				tr.localScale = size * Vector3.one;
				tr.SetParent(transform, false);

				var r = c.GetComponent<Renderer>();
				var block = new MaterialPropertyBlock();
				r.GetPropertyBlock(block);
				var color = baseColor * new Color(Random.value, Random.value, Random.value, 1f);
				block.SetColor(PROP_COLOR, color);
				r.SetPropertyBlock(block);
			}
		}
	}
}