vksync
======

Синхронизация музыки Вконтакте [Linux bash]

Скирпт взят отсюда http://forum.ubuntu.ru/index.php?PHPSESSID=7s4tu71fd71mqo5ak5ld6a5sf5&topic=166168.0<br/>
Немного допилен:
<br/>
*папка хранения скрипта /home/%username%/Музыка/scripts/<br/>
*файлы сохраняются с нормальными именами (в том числе русские)<br/>
*скачанные файлы удаляются после переименования<br/>


Запуск скрипта: <br/>
*sudo chmod +x ./Музыка/script/vksync.sh //делаем файл исполняемым<br/>
*./Музыка/script/vksync.sh //Запускаем скрипт<br/>

Описание работы:<br/>
*берем m3u файл<sup>1</sup> из папки /home/%username%/Музыка/scripts/<br/>
*парсим плейлист<br/>
*скачиваем треки и переименовываем<br/>





1. Можно скачать из Вконтакте, с помощью кучи различных приложений -> MusicSig vkontakte, например для Google Chrome [не является рекламой ни в коем случае]<br/>
