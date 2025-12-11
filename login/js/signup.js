document.getElementById('sign-up').addEventListener('submit', async function(event) {
    console.log('test');
    event.preventDefault();
    const formData = {
        username: event.target.username.value,
        email: event.target.email.value,
        password: event.target.password.value
    }
    console.log('Sign Up Data:', formData);

    const response = fetch('#', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
    })
    const text = await response.text();
    alert(text); // affiche "Success" ou message d'erreur
});