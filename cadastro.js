document.addEventListener('DOMContentLoaded', function() {
    let currentStep = 1;
    const totalSteps = 3;

    // Elementos
    const formCadastro = document.getElementById('formCadastro');
    const steps = document.querySelectorAll('.form-step');
    const progressSteps = document.querySelectorAll('.progress-steps .step');
    const btnNext = document.querySelectorAll('.btn-next');
    const btnPrev = document.querySelectorAll('.btn-prev');
    const btnBuscarCep = document.querySelector('.btn-buscar-cep');

    // Máscaras
    const cpfInput = document.getElementById('cpf');
    const telefoneInput = document.getElementById('telefone');
    const cepInput = document.getElementById('cep');

    // Máscara CPF
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

    // Máscara Telefone
    if (telefoneInput) {
        telefoneInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 11) {
                value = value.replace(/(\d{2})(\d)/, '($1) $2');
                value = value.replace(/(\d{5})(\d)/, '$1-$2');
                e.target.value = value;
            }
        });
    }

    // Máscara CEP
    if (cepInput) {
        cepInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length <= 8) {
                value = value.replace(/(\d{5})(\d)/, '$1-$2');
                e.target.value = value;
            }
        });
    }

    // Buscar CEP
    if (btnBuscarCep) {
        btnBuscarCep.addEventListener('click', async function() {
            const cep = cepInput.value.replace(/\D/g, '');
            
            if (cep.length !== 8) {
                alert('Por favor, insira um CEP válido.');
                return;
            }

            btnBuscarCep.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Buscando...';
            btnBuscarCep.disabled = true;

            try {
                const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
                const data = await response.json();

                if (data.erro) {
                    alert('CEP não encontrado.');
                } else {
                    document.getElementById('rua').value = data.logradouro;
                    document.getElementById('bairro').value = data.bairro;
                    document.getElementById('cidade').value = data.localidade;
                    document.getElementById('numero').focus();
                }
            } catch (error) {
                alert('Erro ao buscar CEP. Tente novamente.');
            } finally {
                btnBuscarCep.innerHTML = '<i class="fas fa-search"></i> Buscar CEP';
                btnBuscarCep.disabled = false;
            }
        });
    }

    // Navegação entre steps
    function showStep(step) {
        steps.forEach((s, index) => {
            s.classList.remove('active');
            progressSteps[index].classList.remove('active', 'completed');
            
            if (index + 1 === step) {
                s.classList.add('active');
                progressSteps[index].classList.add('active');
            } else if (index + 1 < step) {
                progressSteps[index].classList.add('completed');
            }
        });
    }

    // Validar step atual
    function validateCurrentStep() {
        const currentStepElement = document.querySelector(`.form-step[data-step="${currentStep}"]`);
        const inputs = currentStepElement.querySelectorAll('input[required], select[required]');
        
        for (let input of inputs) {
            if (!input.value) {
                alert('Por favor, preencha todos os campos obrigatórios.');
                input.focus();
                return false;
            }

            // Validações específicas
            if (input.id === 'cpf' && input.value.replace(/\D/g, '').length !== 11) {
                alert('Por favor, insira um CPF válido.');
                input.focus();
                return false;
            }

            if (input.id === 'email' && !input.value.includes('@')) {
                alert('Por favor, insira um e-mail válido.');
                input.focus();
                return false;
            }
        }

        return true;
    }

    // Botão Próximo
    btnNext.forEach(btn => {
        btn.addEventListener('click', function() {
            if (validateCurrentStep() && currentStep < totalSteps) {
                currentStep++;
                showStep(currentStep);
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        });
    });

    // Botão Anterior
    btnPrev.forEach(btn => {
        btn.addEventListener('click', function() {
            if (currentStep > 1) {
                currentStep--;
                showStep(currentStep);
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        });
    });

    // Submit do formulário
    if (formCadastro) {
        formCadastro.addEventListener('submit', function(e) {
            e.preventDefault();

            // Validar senha
            const senha = document.getElementById('senha').value;
            const confirmarSenha = document.getElementById('confirmarSenha').value;

            if (senha.length < 6) {
                alert('A senha deve ter pelo menos 6 caracteres.');
                return;
            }

            if (senha !== confirmarSenha) {
                alert('As senhas não coincidem.');
                return;
            }

            // Validar termos
            const termos = document.getElementById('termos');
            if (!termos.checked) {
                alert('Você deve aceitar os Termos de Uso e Política de Privacidade.');
                return;
            }

            // Coletar dados
            const formData = {
                nomeCompleto: document.getElementById('nomeCompleto').value,
                cpf: document.getElementById('cpf').value,
                dataNascimento: document.getElementById('dataNascimento').value,
                telefone: document.getElementById('telefone').value,
                email: document.getElementById('email').value,
                condicao: document.getElementById('condicao').value,
                cep: document.getElementById('cep').value,
                rua: document.getElementById('rua').value,
                numero: document.getElementById('numero').value,
                complemento: document.getElementById('complemento').value,
                bairro: document.getElementById('bairro').value,
                cidade: document.getElementById('cidade').value,
                referencia: document.getElementById('referencia').value,
                senha: senha,
                notificacoes: document.getElementById('notificacoes').checked
            };

            console.log('Dados do cadastro:', formData);

            // Simulação de sucesso
            alert('Cadastro realizado com sucesso!\n\nBem-vindo ao Delivery SUS!');
            
            // Redirecionar para login
            window.location.href = 'login.html';
        });
    }
});