//
//  ContentView.swift
//  duolingo
//
//  Created by rjj.03 on 20/08/2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Game State Variables
    
    // @State 就像是 App 的記憶體。當這些值改變時，畫面會自動更新。
    @State private var score = 0
    @State private var timeRemaining = 10 // 遊戲時間為 10 秒
    @State private var isGameActive = false
    @State private var targetPosition = CGPoint(x: 100, y: 100) // 目標的初始位置
    
    // 建立一個計時器
    // 每 1 秒觸發一次，並在主執行緒上運行
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        // GeometryReader 用來獲取畫面的可用尺寸，這樣我們才能讓目標在安全範圍內隨機移動
        GeometryReader { geometry in
            // ZStack 允許我們將視圖疊加在一起，方便定位目標
            ZStack {
                // 背景顏色
                Color.cyan.opacity(0.3).ignoresSafeArea()
                
                // MARK: - Game UI
                
                VStack(spacing: 20) {
                    // 頂部的分數和時間顯示
                    HStack {
                        Text("分數: \(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer() // Spacer 會佔據所有可用空間，將兩邊的文字推開
                        
                        Text("時間: \(timeRemaining)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // MARK: - Game Area
                    
                    if isGameActive {
                        // 如果遊戲正在進行，顯示目標
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .position(targetPosition) // 將圓圈的位置綁定到我們的狀態變數
                            .onTapGesture {
                                // 當圓圈被點擊時執行的動作
                                score += 1
                                moveTarget(in: geometry.size)
                            }
                    } else {
                        // 如果遊戲未開始或已結束，顯示開始/重新開始按鈕
                        Button(action: startGame) {
                            Text(score == 0 ? "開始遊戲" : "重新開始")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                    }

                    Spacer()
                    Spacer() // 用兩個 Spacer 讓遊戲區域偏上方一點
                }
                .padding()
            }
            // onReceive 用來監聽我們的計時器
            .onReceive(timer) { _ in
                // 每當計時器觸發一次 (也就是每秒)，就執行這裡的程式碼
                if self.isGameActive && self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    if self.timeRemaining == 0 {
                        // 時間到，結束遊戲
                        self.endGame()
                    }
                }
            }
        }
    }

    // MARK: - Game Logic Functions
    
    // 開始遊戲的函式
    func startGame() {
        score = 0
        timeRemaining = 10
        isGameActive = true
        // 我們不能在 startGame 裡直接獲取 geometry.size
        // 所以遊戲開始時，目標會先出現在一個預設位置，然後計時器第一次觸發時會移動它
    }
    
    // 結束遊戲的函式
    func endGame() {
        isGameActive = false
    }
    
    // 移動目標的函式
    func moveTarget(in size: CGSize) {
        // 隨機產生一個新的 x 和 y 座標
        // 我們減去 30 是為了確保圓圈的中心點不會太靠近邊緣，導致部分圓圈超出畫面
        let randomX = CGFloat.random(in: 30...(size.width - 30))
        let randomY = CGFloat.random(in: 30...(size.height - 300)) // 減 300 讓目標不會出現在太下方
        self.targetPosition = CGPoint(x: randomX, y: randomY)
    }
}

#Preview {
    ContentView()
}
