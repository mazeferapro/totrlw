hook.Add('DatabaseInitialized', 'DatabaseInitialized2', function()
    -- Шаг 1: Создание таблицы игроков (nextrp_players)
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_players(
            id int auto_increment not null primary key,
            steam_id varchar(25),
            community_id TEXT,
            discord_id varchar(255),
            char_slots INT,
            referal_code varchar(255),
            referal_code_applied varchar(255)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    ]], function()
        print('Таблица игроков создана успешно!')
        
        -- Шаг 2: Создание таблицы персонажей (nextrp_characters)
        MySQLite.query([[
            CREATE TABLE IF NOT EXISTS nextrp_characters(
                character_id int auto_increment not null primary key,
                player_id INT,
                rpid varchar(255),
                rankid varchar(255),
                flag TEXT,
                character_name varchar(255),
                character_surname varchar(255),
                character_nickname varchar(255),
                team_id varchar(255),
                model varchar(255),
                money int,
                level INT,
                exp INT,
                inventory TEXT,
                talent_points INT DEFAULT 0
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        ]], function()
            print('Таблица персонажей создана успешно!')
            
            -- Шаг 3: Создание таблицы деревьев талантов (nextrp_talent_trees)
            MySQLite.query([[
                CREATE TABLE IF NOT EXISTS nextrp_talent_trees (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    job_id VARCHAR(255) NOT NULL,
                    talent_tree TEXT NOT NULL,
                    UNIQUE KEY (job_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
            ]], function()
                print('Таблица деревьев талантов создана успешно!')
                
                -- Шаг 4: Создание таблицы талантов персонажей (nextrp_character_talents) с внешним ключом
                -- Обратите внимание на обратные кавычки вокруг слова rank
                MySQLite.query([[
                    CREATE TABLE IF NOT EXISTS nextrp_character_talents (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        character_id INT NOT NULL,
                        talent_id VARCHAR(255) NOT NULL,
                        `rank` INT DEFAULT 1,
                        UNIQUE KEY (character_id, talent_id),
                        FOREIGN KEY (character_id) REFERENCES nextrp_characters(character_id) ON DELETE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
                ]], function()
                    print('Таблица талантов персонажей создана успешно!')
                    
                    -- Шаг 5: Создание таблицы доната (nextrp_crotr)
                    MySQLite.query([[
                        CREATE TABLE IF NOT EXISTS nextrp_crotr(
                            community_id VARCHAR(255) not null primary key,
                            table_bought TEXT,
                            crotrs int DEFAULT 0
                        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
                    ]], function()
                        print('Таблица доната создана успешно!')
                        print('Все таблицы успешно созданы и инициализированы!')
                    end, function(err)
                        print('Ошибка создания таблицы доната: ' .. tostring(err))
                    end)
                    
                end, function(err)
                    print('Ошибка создания таблицы талантов персонажей: ' .. tostring(err))
                end)
                
            end, function(err)
                print('Ошибка создания таблицы деревьев талантов: ' .. tostring(err))
            end)
            
        end, function(err)
            print('Ошибка создания таблицы персонажей: ' .. tostring(err))
        end)
        
    end, function(err)
        print('Ошибка создания таблицы игроков: ' .. tostring(err))
    end)
end)