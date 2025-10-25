<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control de Inventario - NextTech Store</title>
    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/app.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .tabs {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .tab {
            padding: 10px 20px;
            background: transparent;
            border: none;
            cursor: pointer;
            font-size: 16px;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }
        
        .tab.active {
            color: #3498db;
            border-bottom-color: #3498db;
        }
        
        .tab:hover {
            color: #3498db;
        }
        
        .tab-content {
            display: none;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .tab-content.active {
            display: block;
        }
        
        .filtros {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
            align-items: end;
        }
        
        .filtro-group {
            display: flex;
            flex-direction: column;
        }
        
        .filtro-group label {
            font-weight: 600;
            margin-bottom: 5px;
            color: #555;
        }
        
        .filtro-group select,
        .filtro-group input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            min-width: 200px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #229954;
        }
        
        .btn-warning {
            background: #f39c12;
            color: white;
        }
        
        .btn-warning:hover {
            background: #e67e22;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        thead {
            background: #34495e;
            color: white;
        }
        
        th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-success {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }
        
        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }
        
        .badge-info {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }
        
        .alert-warning {
            background: #fff3cd;
            color: #856404;
            border-left: 4px solid #ffc107;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏪 Control de Inventario</h1>
            <p>Gestión de bodegas, stock y transferencias</p>
            
            <div class="tabs">
                <button class="tab active" onclick="cambiarTab('inventario')">📦 Inventario</button>
                <button class="tab" onclick="cambiarTab('transferencias')">🚚 Transferencias</button>
                <button class="tab" onclick="cambiarTab('alertas')">⚠️ Alertas</button>
            </div>
        </div>

        <!-- TAB: INVENTARIO -->
        <div id="tab-inventario" class="tab-content active">
            <div class="filtros">
                <div class="filtro-group">
                    <label>Bodega:</label>
                    <select id="filtroBodegaInv">
                        <option value="">Todas las bodegas</option>
                    </select>
                </div>
                <div class="filtro-group">
                    <button class="btn btn-primary" onclick="cargarInventario()">🔍 Filtrar</button>
                </div>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Código</th>
                        <th>Producto</th>
                        <th>Bodega</th>
                        <th>Disponible</th>
                        <th>Reservado</th>
                        <th>En Tránsito</th>
                        <th>Total</th>
                        <th>Estado</th>
                    </tr>
                </thead>
                <tbody id="tablaInventario">
                    <tr><td colspan="8" class="loading">Cargando inventario...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- TAB: TRANSFERENCIAS -->
        <div id="tab-transferencias" class="tab-content">
            <div class="filtros">
                <div class="filtro-group">
                    <label>Estado:</label>
                    <select id="filtroEstado">
                        <option value="">Todos</option>
                        <option value="P">Pendiente</option>
                        <option value="E">Enviada</option>
                        <option value="R">Recibida</option>
                        <option value="C">Cancelada</option>
                    </select>
                </div>
                <div class="filtro-group">
                    <button class="btn btn-primary" onclick="cargarTransferencias()">🔍 Filtrar</button>
                </div>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Número</th>
                        <th>Fecha</th>
                        <th>Origen</th>
                        <th>Destino</th>
                        <th>Estado</th>
                        <th>Observaciones</th>
                    </tr>
                </thead>
                <tbody id="tablaTransferencias">
                    <tr><td colspan="6" class="loading">Cargando transferencias...</td></tr>
                </tbody>
            </table>
        </div>

        <!-- TAB: ALERTAS -->
        <div id="tab-alertas" class="tab-content">
            <div class="alert alert-warning">
                <strong>⚠️ Alertas Activas:</strong> Productos que requieren atención inmediata
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Producto</th>
                        <th>Bodega</th>
                        <th>Tipo</th>
                        <th>Mensaje</th>
                        <th>Stock Actual</th>
                        <th>Stock Mínimo</th>
                    </tr>
                </thead>
                <tbody id="tablaAlertas">
                    <tr><td colspan="6" class="loading">Cargando alertas...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        const API_URL = 'http://localhost:8080/api/inventario';

        // Cambiar entre tabs
        function cambiarTab(tab) {
            // Actualizar botones
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            event.target.classList.add('active');
            
            // Actualizar contenido
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.getElementById('tab-' + tab).classList.add('active');
            
            // Cargar datos
            if (tab === 'inventario') cargarInventario();
            if (tab === 'transferencias') cargarTransferencias();
            if (tab === 'alertas') cargarAlertas();
        }

        // Cargar bodegas en el select
        async function cargarBodegas() {
            try {
                const response = await fetch(API_URL + '/bodegas');
                const bodegas = await response.json();
                
                const select = document.getElementById('filtroBodegaInv');
                bodegas.forEach(bodega => {
                    const option = document.createElement('option');
                    option.value = bodega.id;
                    option.textContent = bodega.nombre;
                    select.appendChild(option);
                });
            } catch (error) {
                console.error('Error cargando bodegas:', error);
            }
        }

        // Cargar inventario
        async function cargarInventario() {
            const bodegaId = document.getElementById('filtroBodegaInv').value;
            const url = bodegaId ? 
                `${API_URL}/inventario?bodegaId=${bodegaId}` : 
                `${API_URL}/inventario`;

            try {
                const response = await fetch(url);
                const inventario = await response.json();
                
                const tbody = document.getElementById('tablaInventario');
                tbody.innerHTML = '';
                
                if (inventario.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="8" class="empty-state">No hay datos de inventario</td></tr>';
                    return;
                }
                
                inventario.forEach(item => {
                    const estado = getEstadoStock(item.cantidad_disponible, item.stock_minimo);
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td>${item.producto_codigo || 'N/A'}</td>
                        <td><strong>${item.producto_nombre || 'N/A'}</strong></td>
                        <td>${item.bodega_nombre || 'N/A'}</td>
                        <td><strong>${item.cantidad_disponible || 0}</strong></td>
                        <td>${item.cantidad_reservada || 0}</td>
                        <td>${item.cantidad_en_transito || 0}</td>
                        <td>${item.cantidad_actual || 0}</td>
                        <td>${estado}</td>
                    `;
                    tbody.appendChild(tr);
                });
            } catch (error) {
                console.error('Error cargando inventario:', error);
                document.getElementById('tablaInventario').innerHTML = 
                    '<tr><td colspan="8" class="empty-state">Error al cargar inventario</td></tr>';
            }
        }

        // Cargar transferencias
        async function cargarTransferencias() {
            const estado = document.getElementById('filtroEstado').value;
            const url = estado ? 
                `${API_URL}/transferencias?estado=${estado}` : 
                `${API_URL}/transferencias`;

            try {
                const response = await fetch(url);
                const transferencias = await response.json();
                
                const tbody = document.getElementById('tablaTransferencias');
                tbody.innerHTML = '';
                
                if (transferencias.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No hay transferencias registradas</td></tr>';
                    return;
                }
                
                transferencias.forEach(t => {
                    const estadoBadge = getEstadoTransferencia(t.estado);
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td><strong>${t.numero_transferencia}</strong></td>
                        <td>${formatearFecha(t.fecha_transferencia)}</td>
                        <td>${t.bodega_origen_nombre}</td>
                        <td>${t.bodega_destino_nombre}</td>
                        <td>${estadoBadge}</td>
                        <td>${t.observaciones || '-'}</td>
                    `;
                    tbody.appendChild(tr);
                });
            } catch (error) {
                console.error('Error cargando transferencias:', error);
                document.getElementById('tablaTransferencias').innerHTML = 
                    '<tr><td colspan="6" class="empty-state">Error al cargar transferencias</td></tr>';
            }
        }

        // Cargar alertas
        async function cargarAlertas() {
            try {
                const response = await fetch(`${API_URL}/alertas?activa=true`);
                const alertas = await response.json();
                
                const tbody = document.getElementById('tablaAlertas');
                tbody.innerHTML = '';
                
                if (alertas.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">✅ No hay alertas activas</td></tr>';
                    return;
                }
                
                alertas.forEach(alerta => {
                    const tipoBadge = getTipoAlerta(alerta.tipo_alerta);
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td><strong>${alerta.producto_nombre}</strong></td>
                        <td>${alerta.bodega_nombre}</td>
                        <td>${tipoBadge}</td>
                        <td>${alerta.mensaje}</td>
                        <td>${alerta.cantidad_actual}</td>
                        <td>${alerta.stock_minimo}</td>
                    `;
                    tbody.appendChild(tr);
                });
            } catch (error) {
                console.error('Error cargando alertas:', error);
                document.getElementById('tablaAlertas').innerHTML = 
                    '<tr><td colspan="6" class="empty-state">Error al cargar alertas</td></tr>';
            }
        }

        // Helpers
        function getEstadoStock(disponible, minimo) {
            if (disponible === 0) {
                return '<span class="badge badge-danger">Sin Stock</span>';
            } else if (disponible <= minimo) {
                return '<span class="badge badge-warning">Stock Bajo</span>';
            } else {
                return '<span class="badge badge-success">OK</span>';
            }
        }

        function getEstadoTransferencia(estado) {
            const estados = {
                'P': '<span class="badge badge-warning">Pendiente</span>',
                'E': '<span class="badge badge-info">Enviada</span>',
                'R': '<span class="badge badge-success">Recibida</span>',
                'C': '<span class="badge badge-danger">Cancelada</span>'
            };
            return estados[estado] || estado;
        }

        function getTipoAlerta(tipo) {
            const tipos = {
                'M': '<span class="badge badge-warning">Stock Mínimo</span>',
                'A': '<span class="badge badge-info">Stock Alto</span>',
                'S': '<span class="badge badge-danger">Sin Stock</span>'
            };
            return tipos[tipo] || tipo;
        }

        function formatearFecha(fecha) {
            if (!fecha) return '-';
            return new Date(fecha).toLocaleDateString('es-GT');
        }

        // Inicializar al cargar la página
        window.onload = function() {
            cargarBodegas();
            cargarInventario();
        };
    </script>
</body>
</html>