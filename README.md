# MarkFlow

Движок автоматизации монтажа для YouTube-канала **Макашенец**.
Работает полностью в облаке — Premiere Pro не открывается до самого финала.

## Что умеет

### Уже работает
| Модуль | Что делает |
|---|---|
| `markflow/profiles/makashenets_style.md` | Style Profile — что любит и что запрещает автор |
| `markflow/profiles/makashenets_config.py` | Машиночитаемый конфиг для модуля classify |
| `markflow/core/cut.py` | Rough-Cut: убирает повторные дубли, команды диктора; оставляет последний лучший вариант |
| `markflow/core/classify.py` | Тегирует сегменты по Style Profile (Putin-момент, цифра, клише, мат...) |
| `markflow/build/build_prproj.py` | Пишет `.prproj` XML напрямую кодом, без живого Premiere |
| `markflow/build/check_project.py` | Валидирует проект по файлу; без «ИТОГ: OK» — не отдаём |

### Тесты
```bash
cd /home/user/Artyopa
python -m markflow.tests.test_cut
python -m markflow.tests.test_build
```

## Как использовать pipeline

```
ASR (GigaAM v2 в облаке)
  → words.json (слово + таймкод)
  → cut.py → segments.json (чистые отрезки без дублей)
  → classify.py → tagged.json (что делать с каждым куском)
  → edit_plan.json (вручную или автоматически)
  → build_prproj.py → project.prproj
  → check_project.py → ИТОГ: OK
  → отдать Артёму
```

## ASR

Уже протестирована и работает. Модель: `sherpa-onnx-nemo-transducer-giga-am-v2-russian-2025-04-19`.
Скорость в облаке ~4.8x быстрее реального времени. Код в `/home/claude/scratch_asr/`.

Документация по найденным решениям и граблям — в `MARKFLOW_HANDOFF.md`.
