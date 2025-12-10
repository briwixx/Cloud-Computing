const signUpButton = document.getElementById('signUp');
const signInButton = document.getElementById('signIn');
const container = document.getElementById('container');

signUpButton.addEventListener('click', () => {
	container.classList.add("right-panel-active");
});

signInButton.addEventListener('click', () => {
	container.classList.remove("right-panel-active");
});

async function updateVisitCount() {
  const backendUrl = window.BACKEND_URL; // injecté automatiquement
  const res = await fetch(`${backendUrl}/api/visit`);
  const data = await res.json();
  document.getElementById("visit-count").textContent = data.count;
}

window.onload = updateVisitCount;
document.getElementById("inc-btn").onclick = updateVisitCount;

