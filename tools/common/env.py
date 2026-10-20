"""Caricamento delle chiavi delle API da .env.

I valori delle chiavi non vengono mai stampati: nei messaggi compare solo il nome
della variabile.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

from dotenv import load_dotenv

PROJECT_ROOT: Path = Path(__file__).resolve().parents[2]
ENV_FILE: Path = PROJECT_ROOT / ".env"


def load_env() -> None:
    """Carica .env dalla radice del progetto; si ferma se il file non esiste.

    I valori di .env vincono su quelli già esportati nella shell (per esempio in
    ~/.zshrc): gli script del progetto usano sempre le chiavi del progetto.
    """
    if not ENV_FILE.exists():
        sys.exit(f"Manca {ENV_FILE.name}: copia .env.example in .env e inserisci le chiavi.")
    load_dotenv(ENV_FILE, override=True)


def require(name: str) -> str:
    """Restituisce il valore di una variabile obbligatoria, senza mai stamparlo."""
    load_env()
    value: str = os.environ.get(name, "").strip()
    if not value:
        sys.exit(f"La variabile {name} in .env è vuota.")
    return value


def is_set(name: str) -> bool:
    """Dice se una variabile è presente e non vuota, senza leggerne il valore fuori."""
    load_env()
    return bool(os.environ.get(name, "").strip())
