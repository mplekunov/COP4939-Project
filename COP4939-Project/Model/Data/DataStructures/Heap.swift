//
//  MaxHeap.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 12/12/23.
//

import Foundation

typealias Comparator<T> = (T, T) -> Int

class Heap<T> {
    private var heap: [T] = []
    private let comparator: Comparator<T>
    
    init(comparator: @escaping Comparator<T>) {
        self.comparator = comparator
    }
    
    func size() -> Int {
        return heap.count
    }
      
    // Insert a new element into the heap
    func insert(_ element: T) {
        heap.append(element)
        var currentIndex = heap.count - 1
          
        // Bubble up the element until the
        // heap property is restored
        while currentIndex > 0 && comparator(heap[currentIndex], heap[(currentIndex - 1) / 2]) > 0 {
            heap.swapAt(currentIndex, (currentIndex - 1) / 2)
            currentIndex = (currentIndex - 1) / 2
        }
    }
      
    // Remove and return the top
    // element of the heap
    func remove() -> T? {
        guard !heap.isEmpty else {
            return nil
        }
          
        let topElement = heap[0]
          
        if heap.count == 1 {
            heap.removeFirst()
        } else {
            
            // Replace the top element
            // with the last element in
            // the heap
            heap[0] = heap.removeLast()
            var currentIndex = 0
              
            // Bubble down the element until
            // the heap property is restored
            while true {
                let leftChildIndex = 2 * currentIndex + 1
                let rightChildIndex = 2 * currentIndex + 2
                  
                // Determine the index of
                // the larger child
                var maxIndex = currentIndex
                if leftChildIndex < heap.count && comparator(heap[leftChildIndex],heap[maxIndex]) > 0 {
                    maxIndex = leftChildIndex
                }
                if rightChildIndex < heap.count && comparator(heap[rightChildIndex], heap[maxIndex]) > 0 {
                    maxIndex = rightChildIndex
                }
                  
                // If the heap property is
                // restored, break out of the loop
                if maxIndex == currentIndex {
                    break
                }
                  
                // Otherwise, swap the current
                // element with its larger child
                heap.swapAt(currentIndex, maxIndex)
                currentIndex = maxIndex
            }
        }
          
        return topElement
    }
      
    // Get the top element of the
    // heap without removing it
    func peek() -> T? {
        return heap.first
    }
      
    // Check if the heap is empty
    var isEmpty: Bool {
        return heap.isEmpty
    }
}
