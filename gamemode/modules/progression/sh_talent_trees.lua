--[[--
    Конфигурация деревьев талантов
    Файл: gamemode/config/sh_talent_trees.lua
    
    Упрощённая конфигурация деревьев прокачки.
    Вместо создания в коде через CreateDefaultTalentTree,
    теперь всё описывается здесь.
    
    КЛЮЧИ:
    - "_default" - базовое дерево для всех профессий
    - "job_id" - дерево для конкретной профессии (перезаписывает _default)
    - "flag_ключ" - дерево для флага/специализации (добавляется к профессии)
]]--

NextRP.TalentTrees = NextRP.TalentTrees or {}

-- ============================================================================
-- БАЗОВОЕ ДЕРЕВО (для всех профессий)
-- ============================================================================
NextRP.TalentTrees["_default"] = {
    name = "Базовые таланты",
    talents = {
        ["health_boost"] = {
            name = "Увеличение здоровья",
            description = "Увеличивает максимальное здоровье персонажа.",
            icon = "icon16/heart.png",
            maxRank = 10,
            position = {x = 1, y = 1},
            effects = {
                health = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
            }
        },
        
        ["armor_expert"] = {
            name = "Эксперт брони",
            description = "Увеличивает максимальную броню персонажа.",
            icon = "icon16/shield.png",
            maxRank = 3,
            position = {x = 2, y = 1},
            effects = {
                armor = {2, 4, 6}
            }
        },
        
        ["speed_demon"] = {
            name = "Скорость демона",
            description = "Увеличивает скорость передвижения персонажа.",
            icon = "icon16/lightning.png",
            maxRank = 5,
            position = {x = 3, y = 1},
            effects = {
                speed = {1, 2, 3, 4, 5}
            }
        }
    }
}

-- ============================================================================
-- ДЕРЕВЬЯ ДЛЯ ПРОФЕССИЙ
-- Ключ = job.id из sh_jobs.lua
-- Если указан inherits = "_default", таланты добавляются к базовым
-- Если не указан inherits, полностью заменяет базовое дерево
-- ============================================================================

NextRP.TalentTrees["rcww"] = {
    name = "RC",
    inherits = "_default",  -- наследует базовые таланты
    talents = {
        ["RC_BactaRegen"] = {
            name = "Ввод Бакты",
            description = "Специальный модуль ввода бакты",
            icon = "icon16/star.png",
            maxRank = 3,
            position = {x = 1, y = 2},
            prerequisites = {"health_boost"},  -- требует изучить health_boost
            effects = {
                healthRegen = {1, 2, 3}
            }
        }
    }
}

NextRP.TalentTrees["mazenrp"] = {
    name = "501-й легион",
    inherits = "_default",  -- наследует базовые таланты
    talents = {
        ["501_training"] = {
            name = "Элитная подготовка",
            description = "Специальная подготовка 501-го легиона.",
            icon = "icon16/star.png",
            maxRank = 3,
            position = {x = 1, y = 2},
            prerequisites = {"health_boost"},  -- требует изучить health_boost
            effects = {
                health = {15, 30, 45}
            }
        }
    }
}

NextRP.TalentTrees["jedi"] = {
    name = "Джедаи",
    inherits = "_default",  -- наследует базовые таланты
    talents = {
        ["jedi_basic_powers"] = {
            name = "Базовые способности силы",
            description = "Изучение базовых способностей силы",
            icon = "icon16/star.png",
            maxRank = 1,
            position = {x = 1, y = 2},
            effects = {
                lscsForcePowers = {"lscs_force_jump", "lscs_force_push", "lscs_force_pull", "lscs_force_adrenaline"}
            }
        }
    }
}

-- ============================================================================
-- ДЕРЕВЬЯ ДЛЯ ФЛАГОВ (СПЕЦИАЛИЗАЦИЙ)
-- Ключ = "flag_" + ключ флага из job.flags
-- Эти таланты добавляются игроку когда у него есть соответствующий флаг
-- ============================================================================

-- Страж
NextRP.TalentTrees["flag_guard"] = {
    name = "Страж",
    talents = {
        ["guard_fortitude"] = {
            name = "Стойкость стража",
            description = "Увеличивает защиту персонажа.",
            icon = "icon16/shield.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                armor = {3, 6, 9}
            }
        }
    }
}

-- Защитник
NextRP.TalentTrees["flag_defender"] = {
    name = "Защитник",
    talents = {
        ["defender_resolve"] = {
            name = "Решимость защитника",
            description = "Увеличивает живучесть персонажа.",
            icon = "icon16/heart.png",
            maxRank = 1,
            position = {x = 1, y = 1},
            effects = {
                lscsForcePowers = {"lscs_force_push", "lscs_force_pull"}
            }
        }
    }
}

-- Консул
NextRP.TalentTrees["flag_Защитник"] = {
    name = "Консул",
    talents = {
        ["consul_wisdom"] = {
            name = "Мудрость консула",
            description = "Увеличивает получаемый опыт.",
            icon = "icon16/book.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                health = {5, 10, 15}
            }
        }
    }
}

-- Коммандер-Джедай
NextRP.TalentTrees["flag_cj"] = {
    name = "Коммандер-Джедай",
    talents = {
        ["cj_leadership"] = {
            name = "Командирское чутьё",
            description = "Улучшает боевые характеристики.",
            icon = "icon16/user_suit.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                health = {10, 20, 30},
                armor = {2, 4, 6}
            }
        }
    }
}

-- Генерал-Джедай
NextRP.TalentTrees["flag_gj"] = {
    name = "Генерал-Джедай",
    talents = {
        ["gj_tactical"] = {
            name = "Тактический гений",
            description = "Улучшает все характеристики.",
            icon = "icon16/star.png",
            maxRank = 5,
            position = {x = 1, y = 1},
            effects = {
                health = {10, 20, 30, 40, 50},
                armor = {1, 2, 3, 4, 5},
                speed = {1, 2, 3, 4, 5}
            }
        }
    }
}

-- Старший Генерал-Джедай
NextRP.TalentTrees["flag_sgj"] = {
    name = "Старший Генерал-Джедай",
    talents = {
        ["sgj_mastery"] = {
            name = "Мастерство генерала",
            description = "Значительно улучшает характеристики.",
            icon = "icon16/medal_gold_1.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                health = {25, 50, 75},
                armor = {5, 10, 15}
            }
        }
    }
}

-- Высший Генерал-Джедай
NextRP.TalentTrees["flag_hgj"] = {
    name = "Высший Генерал-Джедай",
    talents = {
        ["hgj_supreme"] = {
            name = "Высшее командование",
            description = "Максимальное усиление характеристик.",
            icon = "icon16/medal_gold_3.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                health = {35, 70, 105},
                armor = {7, 14, 21}
            }
        }
    }
}

-- Смотрящий за храмом
NextRP.TalentTrees["flag_Temple Watcher"] = {
    name = "Смотрящий за храмом",
    talents = {
        ["tw_vigilance"] = {
            name = "Бдительность",
            description = "Повышает внимательность и защиту.",
            icon = "icon16/eye.png",
            maxRank = 3,
            position = {x = 1, y = 1},
            effects = {
                health = {10, 20, 30},
                armor = {3, 6, 9}
            }
        }
    }
}

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

--- Получить дерево для профессии (с наследованием)
function NextRP.TalentTrees.GetJobTree(jobID)
    local tree = NextRP.TalentTrees[jobID]
    local defaultTree = NextRP.TalentTrees["_default"]
    
    -- Если нет специфичного дерева, возвращаем базовое
    if not tree then
        return defaultTree and table.Copy(defaultTree) or nil
    end
    
    -- Если дерево наследует базовое
    if tree.inherits and NextRP.TalentTrees[tree.inherits] then
        local baseTree = table.Copy(NextRP.TalentTrees[tree.inherits])
        baseTree.name = tree.name or baseTree.name
        baseTree.jobID = jobID
        
        -- Добавляем уникальные таланты
        for talentID, talent in pairs(tree.talents or {}) do
            baseTree.talents[talentID] = talent
        end
        
        return baseTree
    end
    
    local result = table.Copy(tree)
    result.jobID = jobID
    return result
end

--- Получить дерево для флага
function NextRP.TalentTrees.GetFlagTree(flagKey)
    return NextRP.TalentTrees["flag_" .. flagKey]
end

--- Получить полное дерево для игрока (профессия + флаги)
function NextRP.TalentTrees.GetPlayerTree(jobID, flags)
    -- Получаем базовое дерево профессии
    local tree = NextRP.TalentTrees.GetJobTree(jobID)
    
    if not tree then
        tree = {
            jobID = jobID,
            name = "Таланты",
            talents = {}
        }
    end
    
    -- Если нет флагов, возвращаем как есть
    if not flags or not next(flags) then
        return tree
    end
    
    -- Добавляем таланты от флагов
    local flagYOffset = 5  -- Смещение по Y для талантов флагов
    
    for flagKey, _ in pairs(flags) do
        local flagTree = NextRP.TalentTrees.GetFlagTree(flagKey)
        
        if flagTree and flagTree.talents then
            for talentID, talent in pairs(flagTree.talents) do
                local newTalent = table.Copy(talent)
                
                -- Смещаем позицию вниз
                if newTalent.position then
                    newTalent.position = {
                        x = newTalent.position.x,
                        y = newTalent.position.y + flagYOffset
                    }
                end
                
                -- Помечаем как талант от флага
                newTalent.fromFlag = flagKey
                newTalent.flagName = flagTree.name
                
                -- Добавляем с префиксом чтобы избежать конфликтов
                tree.talents["flag_" .. flagKey .. "_" .. talentID] = newTalent
            end
            
            flagYOffset = flagYOffset + 2
        end
    end
    
    return tree
end

print("[NextRP] Конфигурация деревьев талантов загружена!")