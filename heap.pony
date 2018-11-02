
type MinHeap[A: Comparable[A] #read] is BinaryHeap[A, MinHeapPriority[A]]
type MaxHeap[A: Comparable[A] #read] is BinaryHeap[A, MaxHeapPriority[A]]

class BinaryHeap[A: Comparable[A] #read, P: HeapPriority[A]]
  embed _data: Array[A]

  new create(len: USize) =>
    _data = Array[A](len)

  fun ref clear() =>
    _data.clear()

  fun size(): USize =>
    _data.size()

  fun peek(): this->A ? =>
    _data(0)?

  fun ref push(value: A) =>
    """
    Push a value into the heap. The time complexity of this operation is
    O(log(n)) with respect to the size of the heap.
    """
    _data.push(value)
    _sift_up(size() - 1)

  fun ref pop(): A^ ? =>
    """
    Remove the (TODO) value from the heap and return it. The time complexity
    of this operation is O(log(n)) with respect to the size of the heap.
    """
    let n = size() - 1
    _data.swap_elements(0, n)?
    _sift_down(0, n)
    _data.pop()?

  fun ref append(
    seq: (ReadSeq[A] & ReadElement[A^]),
    offset: USize = 0,
    len: USize = -1)
  =>
    _data.append(seq, offset, len)
    _make_heap()

  fun ref concat(iter: Iterator[A^], offset: USize = 0, len: USize = -1) =>
    _data.concat(iter, offset, len)
    _make_heap()

  fun values(): ArrayValues[A, this->Array[A]]^ =>
    _data.values()

  fun ref _make_heap() =>
    let n = size()
    if n < 2 then return end
    var i = (n / 2)
    while (i = i - 1) > 0 do
      _sift_down(i, n)
    end

  fun ref _sift_up(n: USize) =>
    var idx = n
    try
      while true do
        let parent_idx = (idx - 1) / 2
        if (parent_idx == idx) or not P(_data(idx)?, _data(parent_idx)?) then
          break
        end
        _data.swap_elements(parent_idx, idx)?
        idx = parent_idx
      end
    end

  fun ref _sift_down(start: USize, n: USize): Bool =>
    var idx = start
    try
      while true do
        var left = (2 * idx) + 1
        if (left >= n) or (left < 0) then
          break
        end
        let right = left + 1
        if (right < n) and P(_data(right)?, _data(left)?) then
          left = right
        end
        if not P(_data(left)?, _data(idx)?) then
          break
        end
        _data.swap_elements(idx, left)?
        idx = left
      end
    end
    idx > start

  fun _apply(i: USize): this->A ? =>
    _data(i)?

type HeapPriority[A: Comparable[A] #read] is
  ( _HeapPriority[A]
  & (MinHeapPriority[A] | MaxHeapPriority[A]))

interface val _HeapPriority[A: Comparable[A] #read]
  new val create()
  fun apply(x: A, y: A): Bool

primitive MinHeapPriority[A: Comparable[A] #read] is _HeapPriority[A]
  fun apply(x: A, y: A): Bool =>
    x < y

primitive MaxHeapPriority [A: Comparable[A] #read] is _HeapPriority[A]
  fun apply(x: A, y: A): Bool =>
    x > y
