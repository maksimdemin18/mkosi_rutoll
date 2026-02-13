# mkosi_rutoll — сборка образов Ubuntu 24.04 LTS (Noble) через mkosi + Ansible

Идея простая:
- **mkosi** собирает “чистую” Ubuntu в виде готового артефакта (диск-образ или rootfs tar).
- **Ansible** на этапе сборки настраивает систему “как надо” (пользователи, сервисы, установка ваших .deb, конфиги).
- Вся логика в Git → воспроизводимость, контроль версий, быстрая пересборка.

---


### 1) Диск-образ (bootable) для установки на железо/VM

Файл в `mkosi.output/`:
- обычно `*.raw` (иногда `*.raw.zst`/`*.raw.xz` — зависит от mkosi)

Этот файл можно:
- загрузить в VM (qemu/virt-manager)
- записать на диск/USB (через `dd`)
- хранить как “золотой образ” вместо Clonezilla

### 2) Rootfs для Docker (tar)

Файл в `mkosi.output/`:
- `rutoll-docker-noble-x86_64.tar`

Его можно импортировать в Docker:
```bash
docker import mkosi.output/rutoll-docker-noble-x86_64.tar rutoll/noble:latest
docker run --rm -it rutoll/noble:latest bash
```

---

## быстрый старт

### Шаг 0. Скачайте репозиторий

```bash
git clone https://github.com/maksimdemin18/mkosi_rutoll.git
cd mkosi_rutoll
```

### Шаг 1. Установите mkosi (Ubuntu 24.04)

```bash
./scripts/bootstrap-ubuntu24.04.sh
```

### Шаг 2. Соберите базовый образ

```bash
./scripts/build.sh base
```

Готовый файл появится в `mkosi.output/`.

---

## Типы образов

Профиль выбирается командой:
```bash
mkosi build --profile <profile>
```

Или через удобный скрипт:
```bash
./scripts/build.sh <profile>
```

| Профиль | Назначение | Что добавляет |
|---|---|---|
| `base` | базовая ОС | пользователи, auditd, ssh hardening |
| `controller` | контроллер полосы | base + место для ваших .deb |
| `app` | АПП | base + место для ваших .deb |
| `turnpike` | АРМ кассира | base + Xorg + x11vnc |
| `dispatcher` | АРМ диспетчера | base + ubuntu-desktop-minimal + NVIDIA driver |
| `docker` | Docker rootfs | минимальная Ubuntu в tar |

---

## Где класть .deb

Вариант A (самый простой):
1) положить `.deb` в `mkosi.packages/`
2) собрать профиль

Во время сборки Ansible попробует:
- найти `*.deb`
- сделать `dpkg -i` и при необходимости `apt-get -f install`

---

## Внутренний APT-репозиторий

Если пакеты из внутреннего репозитория:

1) отредактируйте:
```
mkosi.sandbox/etc/apt/sources.list.d/internal.list
```

2) создайте локальный файл:
```bash
cp mkosi.local.conf.example mkosi.local.conf
```

3) в `mkosi.local.conf` раскомментируйте:
```
SandboxTrees=mkosi.sandbox
```

---

## Разметка диска (mkosi.repart)

В mkosi **нельзя** одновременно иметь “3 разных root-раздела” — это ломает сборку.

Теперь разметка разбита на варианты:
- `mkosi.repart/root-only` → ESP + `/`
- `mkosi.repart/root-home` → ESP + `/` + `/home`
- `mkosi.repart/root-var` → ESP + `/` + `/var`

Готовые профили:
- `base-root-home`
- `base-root-var`

---

## Где менять настройки пользователей/SSH/audit

Файлы, которые **копируются в образ** (mkosi.extra):
- пользователи: `mkosi.extra/usr/lib/sysusers.d/10-local-users.conf`
- sudo: `mkosi.extra/etc/sudoers.d/99-rutoll`
- ssh hardening: `mkosi.extra/etc/ssh/sshd_config.d/10-hardening.conf`
- journald: `mkosi.extra/etc/systemd/journald.conf.d/10-journald.conf`
- timesyncd: `mkosi.extra/etc/systemd/timesyncd.conf.d/10-timesyncd.conf`

---

## Где менять логику установки сервисов

Ansible роли:
- `ansible/roles/rutoll_base`
- `ansible/roles/rutoll_controller`
- `ansible/roles/rutoll_app`
- `ansible/roles/rutoll_turnpike`
- `ansible/roles/rutoll_dispatcher`

---
