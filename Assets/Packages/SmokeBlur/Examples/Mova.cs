using UnityEngine;
using System.Collections;

namespace WatercolorBlueSystem {

	public class Mova : MonoBehaviour {
		public Vector3 angularVelocity;

		void Update () {
			transform.localRotation *= Quaternion.Euler(angularVelocity * Time.deltaTime);
		}
	}
}