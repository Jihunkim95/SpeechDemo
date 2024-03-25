//
//  ContentView.swift
//  JustTest
//
//  Created by 김지훈 on 2024/03/25.
//


import SwiftUI
import Speech
import AVFoundation


struct ContentView: View {
    @State private var text = "버튼을 눌러 말해보세요..."
    @State private var audioEngine = AVAudioEngine()
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    @State private var request = SFSpeechAudioBufferRecognitionRequest()
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack {
            Text(text)
                .padding()

            Button("녹음 시작") {
                self.requestMicrophonePermission()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
    }

    //마이크, 음성인식 권한설정
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                // 마이크 권한이 허용된 경우, 음성 인식 권한 요청
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    DispatchQueue.main.async {
                        switch authStatus {
                        case .authorized:
                            // 음성 인식 권한도 허용됨, 녹음 시작
                            self.startRecording()
                        default:
                            // 권한 거부 처리
                            self.text = "음성 인식 권한이 거부되었습니다."
                        }
                    }
                }
            } else {
                // 마이크 권한 거부 처리
                DispatchQueue.main.async {
                    self.text = "마이크 권한이 거부되었습니다."
                }
            }
        }
    }

    
    func startRecording() {
        // 이전에 실행 중이던 태스크가 있다면 취소
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // 녹음을 위한 오디오 입력 설정
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        // 오디오 엔진 시작
        audioEngine.prepare()
        try? audioEngine.start()

        // 음성 인식
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                self.text = result.bestTranscription.formattedString
            }

            if error != nil || result?.isFinal == true {
                audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.request = SFSpeechAudioBufferRecognitionRequest()
                self.recognitionTask = nil
            }
        }
    }
}
