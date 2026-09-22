document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const sidebar = document.querySelector('.sidebar');
    const formSolicitacao = document.getElementById('formSolicitacao');

    // Toggle Menu Mobile
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            sidebar.classList.toggle('active');
        });

        // Fechar sidebar ao clicar fora (mobile)
        document.addEventListener('click', function(e) {
            if (window.innerWidth <= 768) {
                if (!sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                    sidebar.classList.remove('active');
                }
            }
        });
    }

    // Navegação ativa
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            if (!this.getAttribute('href').startsWith('http') && this.getAttribute('href') !== '../index.html') {
                e.preventDefault();
                navItems.forEach(nav => nav.classList.remove('active'));
                this.classList.add('active');
                
                // Fechar sidebar no mobile
                if (window.innerWidth <= 768) {
                    sidebar.classList.remove('active');
                }
            }
        });
    });

    // Form Solicitação de Medicamento
    if (formSolicitacao) {
        formSolicitacao.addEventListener('submit', function(e) {
            e.preventDefault();

            const medicamento = document.getElementById('medicamento');
            const quantidade = document.getElementById('quantidade').value;
            const ubs = document.getElementById('ubs');
            const observacoes = document.getElementById('observacoes').value;

            if (!medicamento.value || !ubs.value) {
                alert('Por favor, preencha todos os campos obrigatórios.');
                return;
            }

            const medicamentoNome = medicamento.options[medicamento.selectedIndex].text;
            const ubsNome = ubs.options[ubs.selectedIndex].text;

            const solicitacao = {
                medicamento: medicamentoNome,
                quantidade: quantidade,
                ubs: ubsNome,
                observacoes: observacoes,
                data: new Date().toLocaleDateString('pt-BR'),
                status: 'Aguardando aprovação'
            };

            console.log('Nova solicitação:', solicitacao);

            alert(`Solicitação enviada com sucesso!\n\nMedicamento: ${medicamentoNome}\nQuantidade: ${quantidade}\nUBS: ${ubsNome}\n\nVocê receberá uma notificação quando a solicitação for aprovada.`);

            formSolicitacao.reset();

            // Atualizar estatísticas (simulação)
            atualizarEstatisticas();
        });
    }

    // Atualizar estatísticas
    function atualizarEstatisticas() {
        const statAguardando = document.querySelector('.stat-card:nth-child(3) h3');
        if (statAguardando) {
            const valorAtual = parseInt(statAguardando.textContent);
            statAguardando.textContent = valorAtual + 1;
            
            // Animação
            statAguardando.style.transform = 'scale(1.2)';
            setTimeout(() => {
                statAguardando.style.transform = 'scale(1)';
            }, 300);
        }
    }

    // Notificações
    const notificationIcon = document.querySelector('.notification');
    if (notificationIcon) {
        notificationIcon.addEventListener('click', function() {
            alert('Você tem 3 notificações:\n\n1. Medicamento Losartana entregue com sucesso\n2. Solicitação de Metformina aprovada\n3. Novo medicamento disponível na UBS Pioneiras');
        });
    }

    // Simulação de dados da tabela
    const btnIcons = document.querySelectorAll('.btn-icon');
    btnIcons.forEach((btn, index) => {
        btn.addEventListener('click', function() {
            const row = this.closest('tr');
            const pedido = row.cells[0].textContent;
            const medicamento = row.cells[1].textContent;
            const status = row.cells[3].textContent;

            if (this.querySelector('.fa-eye')) {
                alert(`Detalhes do Pedido ${pedido}\n\nMedicamento: ${medicamento}\nStatus: ${status}\nEntregador: Carlos Silva\nPrevisão: 24/01/2026`);
            } else if (this.querySelector('.fa-map-marker-alt')) {
                alert(`Rastreamento do Pedido ${pedido}\n\n📍 Medicamento separado\n📍 Saiu para entrega\n📍 Em trânsito\n🏠 Previsão de chegada: Hoje às 15:30`);
            }
        });
    });

    // Animações ao carregar
    const cards = document.querySelectorAll('.stat-card, .card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            card.style.transition = 'all 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 100);
    });
});