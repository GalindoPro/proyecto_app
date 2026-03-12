# Cómo usar SQLite3 Editor con Capital Pro

## ¿Dónde está el archivo .db?

La base de datos se guarda automáticamente en el dispositivo/emulador.
Para verla en VS Code necesitas extraerla primero.

---

## En emulador Android (el más fácil)

### Opción 1 — Android Studio Device Explorer
1. Abre Android Studio → View → Tool Windows → Device Explorer
2. Navega a: `data/data/com.tuempresa.capital_pro/databases/`
3. Click derecho → Save As → guarda como `capital_pro.db` en tu proyecto
4. Abre el .db con SQLite3 Editor en VS Code

### Opción 2 — ADB (línea de comandos)
```bash
# Extraer la base de datos del emulador
adb pull /data/data/com.tuempresa.capital_pro/databases/capital_pro.db ./capital_pro.db

# Enviar de regreso al emulador (si la modificaste)
adb push ./capital_pro.db /data/data/com.tuempresa.capital_pro/databases/capital_pro.db
```

### Opción 3 — Flutter desde la app (recomendado para producción)
La app tiene BackupService que exporta el .db directamente.
Ve a: Reportes → Exportar datos → Compartir archivo .db

---

## Abrir en VS Code con SQLite3 Editor

1. Click derecho en el archivo `capital_pro.db`
2. "Open With..." → "SQLite3 Editor"
3. Verás todas las tablas: usuarios, clientes, pagos, prestamos

---

## Tablas y qué esperar ver

### tabla: `clientes`
| id | nombre | apellido | telefono | activo |
|----|--------|----------|----------|--------|
| uuid | Juan | Pérez | 55551234 | 1 |

- `activo = 0` significa eliminado (soft delete)

### tabla: `pagos`
| id | cliente_id | monto | metodo_pago | estado |
|----|-----------|-------|-------------|--------|
| uuid | uuid-cliente | 500.00 | efectivo | completado |

- `estado`: pendiente / completado / cancelado
- `metodo_pago`: efectivo / transferencia / cheque / tarjeta

### tabla: `prestamos`
| id | cliente_id | monto_original | tasa_interes | saldo_pendiente | estado |
|----|-----------|----------------|--------------|-----------------|--------|
| uuid | uuid-cliente | 5000.00 | 5.0 | 3500.00 | activo |

- `tasa_interes`: porcentaje mensual (5.0 = 5%)
- `estado`: activo / pagado / vencido / cancelado

---

## Queries útiles para depuración

Copia y pega en SQLite3 Editor → "Run SQL":

```sql
-- Ver todos los clientes activos
SELECT id, nombre || ' ' || apellido AS nombre_completo, telefono
FROM clientes WHERE activo = 1 ORDER BY nombre;

-- Ver pagos del mes actual
SELECT p.concepto, p.monto, p.estado, p.metodo_pago,
       c.nombre || ' ' || c.apellido AS cliente
FROM pagos p
JOIN clientes c ON p.cliente_id = c.id
WHERE strftime('%Y-%m', p.fecha) = strftime('%Y-%m', 'now')
ORDER BY p.fecha DESC;

-- Ver préstamos vencidos
SELECT pr.id, c.nombre || ' ' || c.apellido AS cliente,
       pr.monto_original, pr.saldo_pendiente,
       pr.fecha_vencimiento, pr.estado
FROM prestamos pr
JOIN clientes c ON pr.cliente_id = c.id
WHERE pr.estado = 'activo'
  AND pr.fecha_vencimiento < datetime('now')
ORDER BY pr.fecha_vencimiento;

-- Resumen financiero rápido
SELECT
  (SELECT COALESCE(SUM(monto), 0) FROM pagos
   WHERE estado = 'completado'
   AND strftime('%Y-%m', fecha) = strftime('%Y-%m', 'now')) AS cobrado_mes,
  (SELECT COALESCE(SUM(monto), 0) FROM pagos WHERE estado = 'pendiente') AS pendiente_total,
  (SELECT COALESCE(SUM(saldo_pendiente), 0) FROM prestamos WHERE estado = 'activo') AS cartera_activa,
  (SELECT COUNT(*) FROM clientes WHERE activo = 1) AS total_clientes,
  (SELECT COUNT(*) FROM prestamos WHERE estado = 'activo') AS prestamos_activos,
  (SELECT COUNT(*) FROM prestamos
   WHERE estado = 'activo' AND fecha_vencimiento < datetime('now')) AS prestamos_vencidos;

-- Top 5 clientes con más pagos
SELECT c.nombre || ' ' || c.apellido AS cliente,
       COUNT(p.id) AS total_pagos,
       SUM(p.monto) AS monto_total
FROM pagos p
JOIN clientes c ON p.cliente_id = c.id
WHERE p.estado = 'completado'
GROUP BY p.cliente_id
ORDER BY monto_total DESC
LIMIT 5;

-- Ver historial de un cliente específico
-- (reemplaza el UUID con uno real)
SELECT 'PAGO' as tipo, concepto, monto, fecha, estado
FROM pagos WHERE cliente_id = 'UUID-DEL-CLIENTE'
UNION ALL
SELECT 'PRESTAMO', 'Préstamo Q'||monto_original, saldo_pendiente,
       fecha_inicio, estado
FROM prestamos WHERE cliente_id = 'UUID-DEL-CLIENTE'
ORDER BY fecha DESC;
```

---

## Datos de prueba para desarrollo

Ejecuta este SQL para insertar datos de prueba:

```sql
-- Cliente de prueba 1
INSERT INTO clientes VALUES (
  'c1111111-1111-1111-1111-111111111111',
  'Juan', 'García', '55551234',
  'juan@email.com', 'Zona 1, Guatemala', '1234567890123',
  NULL, datetime('now', '-30 days'), 1
);

-- Cliente de prueba 2
INSERT INTO clientes VALUES (
  'c2222222-2222-2222-2222-222222222222',
  'María', 'López', '44441234',
  NULL, 'Zona 10, Guatemala', NULL,
  NULL, datetime('now', '-60 days'), 1
);

-- Préstamo activo
INSERT INTO prestamos VALUES (
  'p1111111-1111-1111-1111-111111111111',
  'c1111111-1111-1111-1111-111111111111',
  5000.00, 5.0, 12,
  datetime('now', '-60 days'),
  datetime('now', '+305 days'),
  3800.00, 'activo',
  'Garantía: Vehículo', 'Primer préstamo',
  datetime('now', '-60 days')
);

-- Préstamo vencido (para probar alertas)
INSERT INTO prestamos VALUES (
  'p2222222-2222-2222-2222-222222222222',
  'c2222222-2222-2222-2222-222222222222',
  2000.00, 3.0, 3,
  datetime('now', '-120 days'),
  datetime('now', '-30 days'),
  2000.00, 'activo',
  NULL, 'Vencido sin pagar',
  datetime('now', '-120 days')
);

-- Pagos del mes actual
INSERT INTO pagos VALUES (
  'pg111111-1111-1111-1111-111111111111',
  'c1111111-1111-1111-1111-111111111111',
  'p1111111-1111-1111-1111-111111111111',
  600.00, datetime('now', '-5 days'),
  'efectivo', 'Cuota mensual préstamo',
  'completado', NULL, NULL,
  datetime('now', '-5 days')
);

INSERT INTO pagos VALUES (
  'pg222222-2222-2222-2222-222222222222',
  'c1111111-1111-1111-1111-111111111111',
  NULL,
  200.00, datetime('now', '-2 days'),
  'transferencia', 'Intereses extra',
  'completado', 'Pago voluntario', NULL,
  datetime('now', '-2 days')
);
```
