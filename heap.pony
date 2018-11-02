
type MinHeap[A: Comparable[A] #read] is BinaryHeap[A, MinParent[A]]
type MaxHeap[A: Comparable[A] #read] is BinaryHeap[A, MaxParent[A]]

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
    var j = n
    try
      while true do
        let parent_idx = (j - 1) / 2
        if (parent_idx == j) or not P.ord(_data, j, parent_idx)? then
          break
        end
        _data.swap_elements(parent_idx, j)?
        j = parent_idx
      end
    end

  fun ref _sift_down(start: USize, n: USize): Bool =>
    var i = start
    try
      while true do
        let j1 = (2 * i) + 1
        if (j1 >= n) or (j1 < 0) then
          break
        end
        var j = j1
        let j2 = j1 + 1
        if (j2 < n) and P.ord(_data, j2, j1)? then
          j = j2
        end
        if not P.ord(_data, j, i)? then
          break
        end
        _data.swap_elements(i, j)?
        i = j
      end
    end
    i > start

  fun _apply(i: USize): this->A ? =>
    _data(i)?

type HeapPriority[A: Comparable[A] #read] is
  (_HeapPriority[A]
  & (MinParent[A] | MaxParent[A]))

interface val _HeapPriority[A: Comparable[A] #read]
  new val create()
  fun ord(data: Array[A] box, a: USize, b: USize): Bool ?

primitive MinParent[A: Comparable[A] #read] is _HeapPriority[A]
  fun ord(data: Array[A] box, a: USize, b: USize): Bool ? =>
    data(a)? < data(b)?

primitive MaxParent [A: Comparable[A] #read] is _HeapPriority[A]
  fun ord(data: Array[A] box, a: USize, b: USize): Bool ? =>
    data(a)? > data(b)?
