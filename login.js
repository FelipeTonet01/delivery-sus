document.addEventListener('DOMContentLoaded', function() {
    const formLogin = document.getElementById('formLogin');
    const cpfInput = document.getElementById('cpf');

    // Máscara de CPF
    if (cpfInput) {
        cpfInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 11) {
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d)/, '$1.$2');
                value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
                e.target.value = value;
            }
        });
    }

    // Submit do formulário
    if (formLogin) {
        formLogin.addEventListener('submit', function(e) {
            e.preventDefault();

            const cpf = document.getElementById('cpf').value;
            const senha = document.getElementById('senha').value;
            const lembrar = document.getElementById('lembrar').checked;

            // Validação simples
            if (cpf.replace(/\D/g, '').length !== 11) {
                alert('Por favor, insira um CPF válido.');
                return;
            }

            if (senha.length < 6) {
                alert('A senha deve ter pelo menos 6 caracteres.');
                return;
            }

            // Simulação de login
            console.log('Dados de login:', { cpf, senha, lembrar });

            // Simulação de sucesso
            alert('Login realizado com sucesso!');
            
            // Redirecionar para o dashboard
            window.location.href = 'dashboard.html';
        });
    }
});
