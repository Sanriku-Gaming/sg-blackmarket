CREATE TABLE IF NOT EXISTS blackmarket_ped (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedModel VARCHAR(100),
    pedScenario VARCHAR(100),
    pedCoords JSON,
    spawnDate DATETIME,
    resetDays INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;