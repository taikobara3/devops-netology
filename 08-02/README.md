# Домашнее задание к занятию "2. Работа с Playbook"

## Подготовка к выполнению

1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.
```commandline
$ cat ./prod.yml 
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 10.0.2.15
      ansible_connection: ssh
      ansible_ssh_user: root
#      ansible_ssh_pass: Windows2003
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.
```commandline
cat ./site.yml (дописанный фрагмент)
...
- name: Install vector
  hosts: clickhouse
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_major_version }}/vector-{{ vector_minor_version }}.{{ vector_arch }}.rpm"
        dest: ./vector-{{ vector_minor_version }}.{{ vector_arch }}.rpm
    - name: Install vector packages
      ansible.builtin.yum:
        name:
          - vector-{{ vector_minor_version }}.{{ vector_arch }}.rpm
``` 
```commandline
cat ./vars.yml (дописанный фрагмент)
...
vector_major_version: "0.27.0"
vector_minor_version: "0.27.0-1"
vector_arch: "x86_64"
```
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```co.mmandline
ansible-lint site.yml
Couldn't parse task at site.yml:30 (this task 'ansible.builtin.command' has extra params, which is only allowed in the following modules: meta, win_command, set_fact, add_host, import_role, import_tasks, win_shell, command, shell, include_role, raw, script, include_vars, group_by, include_tasks, include

The error appears to be in '<unicode string>': line 30, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

(could not open file to display line))
{ 'ansible.builtin.command': "clickhouse-client -q 'create database logs;'",
  'changed_when': 'create_db.rc == 0',
  'failed_when': 'create_db.rc != 0 and create_db.rc !=82',
  'name': 'Create database',
  'register': 'create_db',
  'skipped_rules': []}
```
Почему - до конца не понял. Вероятно, что-то с версиями ansible. Поменял "ansible.builtin.command" на "command" - ошибка ушла
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
```commandline
ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP ***********************************************************************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0
```
Выполнение проверки прерывается на этапе инсталяции пакета - при проверке файл дистрибутива реально не закачивается, поэтому в файловой системе его нет.
Добавил игнорирование этой таски при проверке: ignore_errors: "{{ ansible_check_mode }}"
```commandline
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "/tmp/clickhouse-common-static-22.6.3.35.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.6.3.35.noarch.rpm"}

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/clickhouse-common-static-22.6.3.35.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/clickhouse-common-static-22.6.3.35.rpm' found on system"]}
...ignoring

TASK [Create database] ***********************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install vector] ************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] ********************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install vector packages] ***************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'vector-0.27.0-1.x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'vector-0.27.0-1.x86_64.rpm' found on system"]}
...ignoring

PLAY RECAP ***********************************************************************************************************************************************************************
clickhouse-01              : ok=7    changed=2    unreachable=0    failed=0    skipped=1    rescued=1    ignored=2
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
```commandline
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "/tmp/clickhouse-common-static-22.6.3.35.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.6.3.35.noarch.rpm"}

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/clickhouse-common-static-22.6.3.35.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/clickhouse-common-static-22.6.3.35.rpm' found on system"]}
...ignoring

TASK [Pause 15 sec] **************************************************************************************************************************************************************
Pausing for 15 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] ***********************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install vector] ************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] ********************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install vector packages] ***************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'vector-0.27.0-1.x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'vector-0.27.0-1.x86_64.rpm' found on system"]}
...ignoring

PLAY RECAP ***********************************************************************************************************************************************************************
clickhouse-01              : ok=7    changed=2    unreachable=0    failed=0    skipped=1    rescued=1    ignored=2
```
В ряде случаев выполнение плейбука прерывалось на таске "Create database". Опытным путем установил, что не успевает, скорее всего, стартовать демон. Добавил паузу в 5 секунд

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```commandline
nsible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] ********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "/tmp/clickhouse-common-static-22.6.3.35.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:admin_home_t:s0", "size": 259749094, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.6.3.35.noarch.rpm"}

TASK [Get clickhouse distrib] ****************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Pause 5 sec] ***************************************************************************************************************************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install vector] ************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] ********************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install vector packages] ***************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP ***********************************************************************************************************************************************************************
clickhouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
```
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

[https://github.com/taikobara3/devops-netology/blob/main/08-03/playbook/README.md](https://github.com/taikobara3/devops-netology/blob/main/08-03/playbook/README.md)

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
