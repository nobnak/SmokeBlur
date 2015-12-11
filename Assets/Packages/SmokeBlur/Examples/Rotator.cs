using UnityEngine;
using System.Collections;

namespace SmokeBlurSystem {

	public class Rotator : MonoBehaviour {
		public Vector3 angularVelocity;

		void Update () {
			transform.localRotation *= Quaternion.Euler(angularVelocity * Time.deltaTime);
		}
	}
}