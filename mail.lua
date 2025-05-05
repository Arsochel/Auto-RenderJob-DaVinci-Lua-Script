-- Получаем доступ к текущему проекту
local resolve = resolve
local projectManager = resolve:GetProjectManager()
local currentProject = projectManager:GetCurrentProject()
local mediaPool = currentProject:GetMediaPool()

-- Функция для поиска папки "render" в медиапуле
local function findRenderFolder(mediaPool)
    local rootFolder = mediaPool:GetRootFolder()
    local subFolders = rootFolder:GetSubFolders()
    for _, folder in ipairs(subFolders) do
        if folder:GetName() == "render" then
            return folder
        end
    end
    return nil
end

-- Путь для рендера
local targetPath = "C:/Users/artem/Documents/Project's/Diplom/test/"

-- Находим папку "render"
local renderFolder = findRenderFolder(mediaPool)

if renderFolder then
    -- Собираем клипы
    local clips = renderFolder:GetClips()
    local clipItems = {}

    for _, clip in pairs(clips) do
        table.insert(clipItems, clip)
    end

    if #clipItems == 0 then
        print("Нет клипов в папке 'render'.")
        return
    end

    -- Создаём пустой таймлайн
    local timelineName = "Render Timeline"
    local created = mediaPool:CreateEmptyTimeline(timelineName)

    if created then
        print("Создан таймлайн '" .. timelineName .. "'.")

        -- Добавляем клипы в таймлайн
        local added = mediaPool:AppendToTimeline(clipItems)
        if added then
            print("Клипы добавлены в таймлайн.")
        else
            print("Ошибка добавления клипов в таймлайн.")
            return
        end

        -- Устанавливаем этот таймлайн активным
        local timeline = currentProject:GetCurrentTimeline()

        -- Получаем все клипы на первом видеотреке
        local videoTrackIndex = 1
        local trackType = "video"
        local timelineClips = timeline:GetItemListInTrack(trackType, videoTrackIndex)

        for i, clip in ipairs(timelineClips) do
            -- Получаем имя клипа из медиапула
            local clipName = clip:GetName()

            -- Устанавливаем настройки рендера
            local settings = {
                TargetDir = targetPath,
                CustomName = clipName,  -- Используем имя клипа для файла
                ExportVideo = true,
                ExportAudio = true,
                Format = "mp4",
                Codec = "H.264",
                Resolution = "1920x1080",
                -- Задание диапазона рендеринга через параметр "Range"
                RenderRange = "Custom"
            }

            -- Устанавливаем область рендеринга для текущего клипа
            currentProject:SetRenderSettings(settings)

            -- Добавляем джоб для рендера
            local jobAdded = currentProject:AddRenderJob()

            if jobAdded then
                print("Добавлен рендер-джоб для клипа: " .. clipName)
            else
                print("Ошибка при добавлении джоба для клипа: " .. clipName)
            end
        end

    else
        print("Не удалось создать таймлайн.")
    end

else
    print("Папка 'render' не найдена в медиапуле.")
end