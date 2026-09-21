"""Command-line entrypoint for running the Raspberry Pi Edge Monitoring Service."""
import argparse
import json
import os
import sys
from .config import (
    DEVICE_ID,
    EDGE_DB_PATH,
    CLOUD_INGEST_URL,
    DEVICE_API_KEY,
    SAMPLING_INTERVAL_SEC,
    SENSOR_RANGES
)
from .edge.detector import HybridDetector
from .edge.store import LocalStore
from .edge.sync import CloudSynchronizer
from .edge.service import EdgeService
from .sensors.max30102_adapter import MAX30102Adapter
from .sensors.temperature_adapter import TemperatureAdapter
from .sensors.fixture import FixtureGenerator

def main():
    parser = argparse.ArgumentParser(description="Raspberry Pi Edge Health Monitor Daemon")
    parser.add_argument("--iterations", type=int, default=None, help="Number of cycles to run (default: infinite)")
    parser.add_argument("--interval", type=float, default=SAMPLING_INTERVAL_SEC, help="Sampling interval in seconds")
    parser.add_argument("--offline", action="store_true", help="Simulate offline mode (disable cloud sync)")
    parser.add_argument("--fixture", type=str, choices=["normal", "spo2_drop", "tachycardia", "noise_spike", "sensor_fault"],
                        help="Run with deterministic fixture scenario")
    parser.add_argument("--print-pending", action="store_true", help="Print pending queue and exit")
    args = parser.parse_args()

    store = LocalStore(EDGE_DB_PATH)

    if args.print_pending:
        pending = store.pending()
        print(json.dumps(pending, indent=2))
        return

    detector = HybridDetector(SENSOR_RANGES)

    if args.fixture:
        sensors = [FixtureGenerator(args.fixture)]
        print(f"[EDGE] Using fixture scenario: '{args.fixture}'")
    else:
        sensors = [MAX30102Adapter(), TemperatureAdapter()]
        print(f"[EDGE] Active sensors: MAX30102, Temperature")

    synchronizer = None
    if not args.offline:
        synchronizer = CloudSynchronizer(
            store=store,
            cloud_url=CLOUD_INGEST_URL,
            device_id=DEVICE_ID,
            device_api_key=DEVICE_API_KEY
        )
        print(f"[EDGE] Cloud sync enabled targeting: {CLOUD_INGEST_URL}")
    else:
        print("[EDGE] Offline mode active: observations will accumulate in local SQLite queue.")

    service = EdgeService(
        device_id=DEVICE_ID,
        sensors=sensors,
        detector=detector,
        store=store,
        synchronizer=synchronizer
    )

    print(f"[EDGE] Starting service for device '{DEVICE_ID}'...")
    try:
        service.run_loop(interval_sec=args.interval, max_iterations=args.iterations)
    except KeyboardInterrupt:
        print("\n[EDGE] Stopped by operator.")
    finally:
        store.close()

if __name__ == "__main__":
    main()
