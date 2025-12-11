const signUpButton = document.getElementById('signUp');
const signInButton = document.getElementById('signIn');
const container = document.getElementById('container');

console.log("BACKEND_URL dans le navigateur :", window.BACKEND_URL);

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
} //test commentaire

window.onload = updateVisitCount;
document.getElementById("inc-btn").onclick = updateVisitCount;

