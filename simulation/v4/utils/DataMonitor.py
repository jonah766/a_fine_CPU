
# cocotb
import cocotb
from cocotb.binary import BinaryValue
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.triggers import Timer, RisingEdge, First

# stdlib
from typing import Any, Dict, List

# for metaclass
import abc

class DataMonitorInterface(metaclass=abc.ABCMeta):
    """
    Samples a value every tsample ns, with an offset of tdelay
    """

    @classmethod
    def __subclasshook__(cls, subclass):
        return (hasattr(subclass, '_run') and  callable(subclass._run) and
                hasattr(subclass, '__init__') and  callable(subclass.__init__))

    @abc.abstractmethod
    def __init__(
        self, datas: Dict[str, SimHandleBase]
    ):  
        self.values = Queue[Dict[str, BinaryValue]]()
        self._datas = datas
        self._coro  = None

    def start(self) -> None:
        """Start monitor"""
        if self._coro is not None:
            raise RuntimeError("Monitor already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self) -> None:
        """Stop monitor"""
        if self._coro is None:
            raise RuntimeError("Monitor never started")
        self._coro.kill()
        self._coro = None

    def _sample(self) -> Dict[str, BinaryValue]:
        """
        Samples the data signals and builds a transaction object
        Return value is what is stored in queue.
        """
        return { 
            name: handle.value for name, handle in self._datas.items()
        }

    @abc.abstractmethod
    async def _run(self) -> None:
        raise NotImplementedError

class SyncDataMonitor(DataMonitorInterface):
    """
    Reusable Monitor of one-way control flow (data/valid) streaming data interface
    Args
        datas: named handles to be sampled when transaction occurs
    """
    def __init__(
        self, ncycles_delay : int, ncycles_step : int, clk: SimHandleBase, datas: Dict[str, SimHandleBase]
    ):  
        self._ncycles_delay = ncycles_delay
        self._ncycles_step  = ncycles_step
        self._clk           = clk
        self.values         = Queue[Dict[str, BinaryValue]]()
        self._datas         = datas
        self._coro          = None

    async def _run(self) -> None:
        for _ in range(self._ncycles_delay):
            await RisingEdge(self._clk)
        while True:
            await RisingEdge(self._clk)
            self.values.put_nowait(self._sample())
            for _ in range(self._ncycles_step-1):
                await RisingEdge(self._clk)


class TimedDataMonitor(DataMonitorInterface):
    """
    Samples a value every tsample ns, with an offset of tdelay
    """
    def __init__(
        self, tdelay : int, tsample : int, datas: Dict[str, SimHandleBase]
    ):  
        self._tdelay  = tdelay
        self._tsample = tsample
        self.values   = Queue[Dict[str, BinaryValue]]()
        self._datas   = datas
        self._coro    = None

    async def _run(self) -> None:
        await Timer(self._tdelay, units="ns")
        while True:
            #await First(*[RisingEdge(handle) for handle in self._datas.values()]) # samples when any of the monitored values change
            await Timer(self._tsample, units="ns")
            self.values.put_nowait(self._sample())

class CombDataMonitor(DataMonitorInterface):
    """
    Samples a set of 1-bit combinatorial signals, triggers when first of monitored signals changes
    """
    def __init__(
        self, tdelay : int, tsample : int, datas: Dict[str, SimHandleBase]
    ):  
        self._tdelay  = tdelay
        self._tsample = tsample
        self.values   = Queue[Dict[str, BinaryValue]]()
        self._datas   = datas
        self._coro    = None

    async def _run(self) -> None:
        await Timer(self._tdelay, units="ns")
        while True:
            await First(*[RisingEdge(handle) for handle in self._datas.values()]) # samples when any of the monitored values change
            self.values.put_nowait(self._sample())