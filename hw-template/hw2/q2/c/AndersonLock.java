package q2.c;

import java.util.concurrent.atomic.AtomicInteger;

public class AndersonLock {
    private AtomicInteger tailSlot = new AtomicInteger(0);
    private boolean[] Available;
    private ThreadLocal<Integer> mySlot = ThreadLocal.withInitial(() -> 0);
    private int numThreads;

    public AndersonLock(int numThreads){
        this.numThreads = numThreads;
        Available = new boolean[numThreads];
        Available[0] = true;
    }

    public void lock() {
        mySlot.set(tailSlot.getAndIncrement() % numThreads);
        while (!Available[mySlot.get()]){}
    }
    public void unlock() {
        int slot = mySlot.get();
        Available[slot] = false;
        Available[(slot + 1) % numThreads] = true;
    }
}
