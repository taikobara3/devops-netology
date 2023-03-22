# Clickhouse

## Что делает playbook:

Playbook разворачивает на заданных хостах приложения:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
- vector
- lighthouse

Запускает clickhouse-server, создает базу данных

Запускает nginx (доступ к странице lighthouse по адресу http://[адрес_хоста_lighthouse]/lighthouse-master)

Плейбук рассчитан на использование только на машинах, управляемых ОС с пакетным менеджером yum, и тестировался только на Centos 7

## Параметры
- IP целевых хостов надо задать в параметре ansible_host файла inventory/prod.yml (хост для развертывания трех приложений clickhouse - в секции clickhouse-01, хост для развертывания vector -  секции vector-01, для развертывания lighthouse и вспомогательного веб-сервера - в секции lighthouse-01 ), там же указать пользователя ssh для которого настроен вход по сертификату, приватный ключ которого указывается здесь же
- пользователь, под именем которого ansible будет осуществлять вход на удаленный хост, указывается в этом же файле, в параметре ansible_ssh_user. В домашней директории этого пользователя, в директории ~/.ssh должен располагаться публичный ключ, приватная часть которого указана в переменной ansible_ssh_private_key_file каждой хостовой секции этого файла. Внимание! Пееред использование плейбука,надо либо осуществить вход по ssh интерактивно, либо запустить плейбук в интерактивном режиме, для принятия отпечатка публичного ключа на удаленных управляемых хостах. 
- этот пользователь должен быть в группе sudo с правами root для запуска менеджера приложений, изменений прав на файлах и директориях, запуска и остановки демонов. 
- версия Vector может быть указана в переменный роли roles/vector-role/defaults/main.yml
- Для роли Сickhouse возможна конфигурация следующих параметров:

Версии:
```commandline
clickhouse_version: "19.11.3.11"
```
Прослушиваемых портов:
```commandline
clickhouse_tcp_port: 9000
clickhouse_interserver_http: 9009
```
IP хоста для прослушивания: 
```
clickhouse_listen_host_custom:
  - "192.168.0.1"
```
А также других переменных, описанных в README роли для roles/ansible-clickhouse/defaults/main.yml
- Для роли ClickHouse, входящей в состав playbook возможны атомарные операции:

Tag | Action
------------ | -------------
install | Только установка пакета
config_sys | Только конфигурация системных параметров (users.xml и config.xml)
config_db | Только добавление\удаление базы данных
config | config_sys+config_db


## Теги
- clickhouse
- vector
- lighthouse