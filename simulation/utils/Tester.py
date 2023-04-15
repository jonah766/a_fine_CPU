from . import SyncDataMonitor, CombDataMonitor, TimedDataMonitor

# cocotb
import cocotb
from cocotb.handle import SimHandleBase

# metaclasses
import abc

class Tester(metaclass=abc.ABCMeta):
    """
    Reusable checker of a module instance
    """

    @classmethod
    def __subclasshook__(cls, subclass):
        return (hasattr(subclass, '_model')   and callable(subclass._model)   and
                hasattr(subclass, '__init__') and callable(subclass.__init__) and
                hasattr(subclass, '_check')   and callable(subclass._check))

    @abc.abstractmethod
    def __init__(self, dut_entity : SimHandleBase):
        self.dut = dut_entity
        self.input_mon = TimedDataMonitor(
            tsample=0,
            tdelay=0,
            datas=dict()
        )
        self.output_mon = TimedDataMonitor(
            tsample=0,
            tdelay=0,
            datas=dict()
        )
        self._checker = None

    def start(self) -> None:
        """Starts monitors, model, and checker coroutine"""
        if self._checker is not None:
            raise RuntimeError("Monitor already started")
        self.input_mon.start()
        self.output_mon.start()
        self._checker = cocotb.start_soon(self._check())

    def stop(self) -> None:
        """Stops everything"""
        if self._checker is None:
            raise RuntimeError("Monitor never started")
        self.input_mon.stop()
        self.output_mon.stop()
        self._checker.kill()
        self._checker = None

    @abc.abstractmethod
    def _model(self):
        """ models the ideal result as a function of the provided inputs"""
        raise NotImplementedError

    @abc.abstractmethod
    async def _check(self) -> None:
        """checks the actual results are equal to the modelled expected result"""
        raise NotImplementedError