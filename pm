<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8" />
  <title>🚚 Agenda Transportes Camilo de Sousa 🚚</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background: #eef2f3;
      margin: 0;
    }

    h1 {
      text-align: center;
      color: #2c3e50;
    }

    form, table {
      max-width: 1000px;
      margin: 20px auto;
    }

    label {
      display: block;
      margin: 10px 0 5px;
    }

    input, select, button, textarea {
      width: 100%;
      padding: 10px;
      margin-bottom: 10px;
      border: 1px solid #ccc;
      border-radius: 6px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 30px;
      background-color: white;
    }

    th, td {
      border: 1px solid #ccc;
      padding: 10px;
      text-align: center;
    }

    th {
      background-color: #2980b9;
      color: white;
      position: sticky;
      top: 0;
      z-index: 1;
    }

    tr:nth-child(even) {
      background-color: #f2f9fc;
    }

    .btn {
      padding: 6px 12px;
      margin: 0 2px;
      cursor: pointer;
      border-radius: 4px;
      border: none;
      transition: 0.3s;
    }

    .edit-btn {
      background-color: #f39c12;
      color: white;
    }

    .edit-btn:hover {
      background-color: #e67e22;
    }

    .delete-btn {
      background-color: #c0392b;
      color: white;
    }

    .delete-btn:hover {
      background-color: #a93226;
    }

    .search-box {
      max-width: 1000px;
      margin: 20px auto;
    }

    .success-msg {
      text-align: center;
      color: green;
      font-weight: bold;
    }

    .passada {
      color: #999;
      text-decoration: line-through;
    }
  </style>
</head>
<body>

<h1>🚚 Agenda Transportes Camilo de Sousa 🚚</h1>

<div class="search-box">
  <input type="text" id="search" placeholder="🔍 Procurar por cliente..." />
</div>

<form id="agenda-form">
  <input type="hidden" id="editIndex">

  <label for="data">Data:</label>
  <input type="date" id="data" required>

  <label for="hora">Hora:</label>
  <select id="hora" required>
    <option value="">--Selecionar Hora--</option>
    ${[...Array(13)].map((_, i) => {
      const hora = (7 + i).toString().padStart(2, '0') + ":00";
      return `<option value="${hora}">${hora}</option>`;
    }).join('')}
  </select>

  <label for="cliente">Nome do Cliente:</label>
  <input type="text" id="cliente" required>

  <label for="telefone">Número de Telemóvel:</label>
  <input type="text" id="telefone" required>

  <label for="tipoCarga">Tipo de Carga:</label>
  <input type="text" id="tipoCarga" required>

  <label for="moradaRecolha">Morada de Recolha:</label>
  <textarea id="moradaRecolha" rows="2" required></textarea>

  <label for="moradaEntrega">Morada de Entrega:</label>
  <textarea id="moradaEntrega" rows="2" required></textarea>

  <label for="viatura">Viatura:</label>
  <select id="viatura" required>
    <option value="">--Selecionar--</option>
    <option value="N10 com grua">N10 com grua</option>
    <option value="Renault">Renault</option>
  </select>

  <button type="submit">💾 Guardar Marcação</button>
  <p class="success-msg" id="sucesso" style="display:none;">✅ Marcação guardada com sucesso!</p>
</form>

<table id="agenda-tabela">
  <thead>
    <tr>
      <th>Data</th>
      <th>Hora</th>
      <th>Cliente</th>
      <th>Telefone</th>
      <th>Tipo de Carga</th>
      <th>Morada de Recolha</th>
      <th>Morada de Entrega</th>
      <th>Viatura</th>
      <th>Ações</th>
    </tr>
  </thead>
  <tbody></tbody>
</table>

<script>
  const form = document.getElementById('agenda-form');
  const tabela = document.getElementById('agenda-tabela').querySelector('tbody');
  const search = document.getElementById('search');
  const sucesso = document.getElementById('sucesso');
  const meses = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"];
  const diasSemana = ["Domingo","Segunda-feira","Terça-feira","Quarta-feira","Quinta-feira","Sexta-feira","Sábado"];
  let marcacoes = JSON.parse(localStorage.getItem('marcacoes')) || [];

  function formatarData(data) {
    const d = new Date(data);
    const dia = d.getDate();
    const mes = meses[d.getMonth()];
    const ano = d.getFullYear();
    const diaSemana = diasSemana[d.getDay()];
    return `${diaSemana}, ${dia} de ${mes} de ${ano}`;
  }

  function validarDiaSemana() {
    const dataSelecionada = document.getElementById('data').value;
    if (dataSelecionada) {
      const data = new Date(dataSelecionada);
      const diaSemana = data.getDay();
      if (diaSemana === 0 || diaSemana === 6) {
        alert("Não é permitido selecionar sábado ou domingo.");
        document.getElementById('data').value = "";
      }
    }
  }

  function renderTabela() {
    const filtro = search.value.toLowerCase();
    const agora = new Date();
    tabela.innerHTML = "";
    marcacoes
      .sort((a, b) => new Date(a.rawData + 'T' + a.hora) - new Date(b.rawData + 'T' + b.hora))
      .forEach((m, index) => {
        if (m.cliente.toLowerCase().includes(filtro)) {
          const dataHora = new Date(m.rawData + 'T' + m.hora);
          const classe = dataHora < agora ? 'passada' : '';
          tabela.innerHTML += `
            <tr class="${classe}">
              <td>${m.data}</td>
              <td>${m.hora}</td>
              <td>${m.cliente}</td>
              <td>${m.telefone}</td>
              <td>${m.tipoCarga}</td>
              <td>${m.moradaRecolha}</td>
              <td>${m.moradaEntrega}</td>
              <td>${m.viatura}</td>
              <td>
                <button class="btn edit-btn" onclick="editarMarcacao(${index})">✏️</button>
                <button class="btn delete-btn" onclick="apagarMarcacao(${index})">🗑️</button>
              </td>
            </tr>
          `;
        }
      });
  }

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    const editIndex = document.getElementById('editIndex').value;
    const dataInput = document.getElementById('data').value;

    const novaMarcacao = {
      rawData: dataInput,
      data: formatarData(dataInput),
      hora: document.getElementById('hora').value,
      cliente: document.getElementById('cliente').value,
      telefone: document.getElementById('telefone').value,
      tipoCarga: document.getElementById('tipoCarga').value,
      moradaRecolha: document.getElementById('moradaRecolha').value,
      moradaEntrega: document.getElementById('moradaEntrega').value,
      viatura: document.getElementById('viatura').value
    };

    const conflito = marcacoes.some((m, i) =>
      m.rawData === novaMarcacao.rawData &&
      m.hora === novaMarcacao.hora &&
      i != editIndex
    );

    if (conflito) {
      alert("Já existe uma marcação para esta data e hora!");
      return;
    }

    if (editIndex === "") {
      marcacoes.push(novaMarcacao);
    } else {
      marcacoes[editIndex] = novaMarcacao;
      document.getElementById('editIndex').value = "";
    }

    localStorage.setItem('marcacoes', JSON.stringify(marcacoes));
    renderTabela();
    form.reset();
    sucesso.style.display = "block";
    setTimeout(() => sucesso.style.display = "none", 2000);
  });

  function apagarMarcacao(index) {
    if (confirm("Tem a certeza que quer apagar esta marcação?")) {
      marcacoes.splice(index, 1);
      localStorage.setItem('marcacoes', JSON.stringify(marcacoes));
      renderTabela();
    }
  }

  function editarMarcacao(index) {
    const m = marcacoes[index];
    document.getElementById('data').value = m.rawData;
    document.getElementById('hora').value = m.hora;
    document.getElementById('cliente').value = m.cliente;
    document.getElementById('telefone').value = m.telefone;
    document.getElementById('tipoCarga').value = m.tipoCarga;
    document.getElementById('moradaRecolha').value = m.moradaRecolha;
    document.getElementById('moradaEntrega').value = m.moradaEntrega;
    document.getElementById('viatura').value = m.viatura;
    document.getElementById('editIndex').value = index;
  }

  search.addEventListener('input', renderTabela);
  document.getElementById('data').addEventListener('change', validarDiaSemana);
  renderTabela();
</script>

</body>
</html>
