"""Mostra i crediti di Meshy, ElevenLabs e Scenario rispetto alla riserva, o controlla una spesa.

Uso:
    python3 tools/credits.py                  # stato di tutti i servizi
    python3 tools/credits.py meshy 30         # questa spesa è permessa? (exit 0 sì, 2 no)

I limiti sono in tools/credit_limits.json. Non serve l'ambiente virtuale.
"""

from __future__ import annotations

import sys

from common.credits import SERVICES, CreditsUnavailable, check, load_limits, remaining


def main(argv: list[str]) -> int:
    if len(argv) == 2:
        service, cost = argv[0], argv[1]
        if service not in SERVICES or not cost.isdigit():
            print(__doc__)
            return 1
        verdict = check(service, int(cost))
        print(verdict.message)
        return 0 if verdict.allowed else 2
    if argv:
        print(__doc__)
        return 1
    limits: dict = load_limits()
    for service in SERVICES:
        config: dict = limits[service]
        try:
            left: int = remaining(service, limits)
        except CreditsUnavailable as error:
            print(f"{service}: non leggibile ({error})")
            continue
        spendable: int = max(left - int(config["reserve"]), 0)
        print(f"{service}: rimasti {left} {config['unit']}, riserva {config['reserve']}, spendibili {spendable}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
