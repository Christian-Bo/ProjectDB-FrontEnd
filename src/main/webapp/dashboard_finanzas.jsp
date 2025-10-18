<%-- 
    Document   : dashboard_finanzas
    Created on : 16/10/2025, 16:50:27
    Author     : Christian
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FINANZAS Dashboard • NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/app.css">
  <script src="assets/js/auth.guard.js"></script>
</head>
<body class="nt-bg">
<script>Auth.ensure(['FINANZAS']);</script>

<header class="navbar navbar-expand-lg nt-header">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="#">NextTech</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0" id="menu-items"></ul>
      <div class="d-flex align-items-center gap-3">
        <span id="user-role" class="badge bg-secondary"></span>
        <button class="btn btn-outline-light btn-sm" onclick="logout()">Salir</button>
      </div>
    </div>
  </div>
</header>

<script>
(function(){
  const r = (Auth.role()||'').toUpperCase();
  document.getElementById('user-role').textContent = r;

  // Módulos permitidos para FINANZAS
  const MODULES = [
    { name:'CxP',               href:'cxp.jsp'             },
    { name:'CxC',               href:'cxc.jsp'             },
    { name:'Compras',           href:'compras.jsp'         },
    { name:'Pagos de Compras',  href:'compras_pagos.jsp'   },
    { name:'Ventas',            href:'ventas.jsp'          }, // consulta
    { name:'Proveedores',       href:'proveedores.jsp'     },
    { name:'Catálogos',         href:'catalogos.jsp'       }
  ];

  const menu = document.getElementById('menu-items');
  menu.innerHTML = MODULES.map(m => `<li class="nav-item"><a class="nav-link" href="${m.href}">${m.name}</a></li>`).join('');
})();
function logout(){ try{ localStorage.removeItem('nt.session'); }catch{} location.href='index.jsp'; }
</script>

<main class="container py-4">
  <h1 class="display-6 mb-4">FINANZAS • Dashboard</h1>
  <div class="row g-3">
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="cxp.jsp">
        <div class="card-body"><h5 class="card-title">CxP</h5><p class="card-text">Documentos y pagos.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="cxc.jsp">
        <div class="card-body"><h5 class="card-title">CxC</h5><p class="card-text">Cobros/clientes.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="compras.jsp">
        <div class="card-body"><h5 class="card-title">Compras</h5><p class="card-text">Soporte a compras.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="compras_pagos.jsp">
        <div class="card-body"><h5 class="card-title">Pagos de compras</h5><p class="card-text">Aplicaciones y conciliación.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="ventas.jsp">
        <div class="card-body"><h5 class="card-title">Ventas</h5><p class="card-text">Consulta para conciliación.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="proveedores.jsp">
        <div class="card-body"><h5 class="card-title">Proveedores</h5><p class="card-text">Datos y estados.</p></div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none" href="catalogos.jsp">
        <div class="card-body"><h5 class="card-title">Catálogos</h5><p class="card-text">Auxiliares contables.</p></div>
      </a>
    </div>
  </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
