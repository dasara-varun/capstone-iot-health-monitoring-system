"""Abstract base sensor interface."""
from abc import ABC, abstractmethod
from typing import List
from ..edge.models import Sample

class BaseSensor(ABC):
    @abstractmethod
    def read_samples(self) -> List[Sample]:
        """Reads one or more sensor samples with timestamps."""
        pass

    @abstractmethod
    def is_hardware_present(self) -> bool:
        """Returns True if physical sensor hardware is detected."""
        pass
