# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

Манифесты deployment'ов:

[yaml-конфигурация Frontend](./deploy_front.yaml)

[yaml-конфигурация Backend](./deploy_back.yaml)

[yaml-конфигурация Cache](./deploy_cache.yaml)

Разворачиваем deployment'ы приложений:

![13-03-01](./13-03-01.png)

![13-03-02](./13-03-02.png)

![13-03-03](./13-03-03.png)

![13-03-04](./13-03-04.png)

[yaml-конфигурация NetworkPolicy](./policy.yaml)

Применяем манифест NetworkPolicy и проверяем доступность:

![13-03-05](./13-03-05.png)