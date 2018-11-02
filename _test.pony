use "collections"
use "ponytest"
use "random"
use "time"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_TestHeap)

class iso _TestHeap is UnitTest
  fun name(): String =>
    "BinaryHeap"

  fun apply(t: TestHelper) ? =>
    _gen_test(t, Time.millis())?

  fun _gen_test(t: TestHelper, seed: U64) ? =>
    let rand = Rand(seed)
    let len = rand.int[USize](100)

    let ns = Array[USize](len)
    for _ in Range(0, len) do
      ns.push(rand.int[USize](100))
    end

    _test_push[MinHeapPriority[USize]](t, ns)?
    _test_push[MaxHeapPriority[USize]](t, ns)?
    _test_append[MinHeapPriority[USize]](t, ns)?
    _test_append[MaxHeapPriority[USize]](t, ns)?
    _test_pop[MinHeapPriority[USize]](t, ns)?
    _test_pop[MaxHeapPriority[USize]](t, ns)?

  fun _test_push[P: HeapPriority[USize]](t: TestHelper, ns: Array[USize]) ? =>
    let h = BinaryHeap[USize, P](ns.size())
    for n in ns.values() do
      h.push(n)
      _verify[P](t, h)?
    end
    t.assert_eq[USize](h.size(), ns.size())

  fun _test_append[P: HeapPriority[USize]](t: TestHelper, ns: Array[USize]) ? =>
    let h = BinaryHeap[USize, P](ns.size())
    h.append(ns)
    t.assert_eq[USize](h.size(), ns.size())
    _verify[P](t, h)?

  fun _test_pop[P: HeapPriority[USize]](t: TestHelper, ns: Array[USize]) ? =>
    let h = BinaryHeap[USize, P](ns.size())
    h.append(ns)

    if ns.size() == 0 then return end

    var prev = h.pop()?
    _verify[P](t, h)?

    for _ in Range(1, ns.size()) do
      let n = h.pop()?
      t.assert_true((prev == n) or P(prev, n))
      prev = n
      _verify[P](t, h)?
    end
    t.assert_eq[USize](h.size(), 0)

  fun _verify[P: HeapPriority[USize]]
    (t: TestHelper, h: BinaryHeap[USize, P], i: USize = 0) ?
  =>
    let a = (2 * i) + 1
    let b = a + 1

    if a < h.size() then
      t.assert_false(P(h._apply(a)?, h._apply(i)?))
      _verify[P](t, h, a)?
    end
    if b < h.size() then
      t.assert_false(P(h._apply(b)?, h._apply(i)?))
      _verify[P](t, h, b)?
    end
