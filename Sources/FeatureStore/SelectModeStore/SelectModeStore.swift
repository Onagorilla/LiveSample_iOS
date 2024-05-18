//
//  File.swift
//
//
//  Created by toya.suzuki on 2024/04/01.
//

import Foundation
import ComposableArchitecture
import User
import UserDefaults
import API

@Reducer
public struct SelectMode {
    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action.Alert>?
        
        public var userRegist: UserRegist
        
        public init(userRegist: UserRegist) {
            self.userRegist = userRegist
        }
    }
    
    public enum Action {
        case didTapFan
        case didTapMusician
        case registerAccountTypeResponse(Result<RegisterAccountTypeResponse, Error>)
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable {
            case failToRegisterAccountType
        }
    }
    
    public init() {}
    
    // MARK: - Dependencies
    @Dependency(\.registerAccountTypeClient) var registerAccountTypeClient
    @Dependency(\.userDefaults) var userDefaults
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapFan:
                guard let sessionId = userDefaults.sessionId else {
                    print("check: No Session ID ")
                    return .none
                }
                
                return .run { send in
                    await send(.registerAccountTypeResponse(Result {
                        try await registerAccountTypeClient.send(sessionId: sessionId, accountType: "fan")
                    }))
                }
                
            case .didTapMusician:
                guard let sessionId = userDefaults.sessionId else {
                    print("check: No Session ID ")
                    return .none
                }
                
                state.userRegist.isMusician = true
                return .run { send in
                    await send(.registerAccountTypeResponse(Result {
                        try await registerAccountTypeClient.send(sessionId: sessionId, accountType: "artist")
                    }))
                }
                
            case let .registerAccountTypeResponse(.success(response)):
                NotificationCenter.default.post(name: NSNotification.didFinishRegisterAccountInfo, object: nil, userInfo: nil)
                return .none
                
            case let .registerAccountTypeResponse(.failure(error)):
                state.alert = AlertState(title: TextState("登録失敗"))
                return .none
                
            case .alert(.presented(.failToRegisterAccountType)):
                return .none
                
            case .alert:
                return .none
            }
        }
    }
}

extension NSNotification {
    public static let didFinishRegisterAccountInfo = Notification.Name.init("didFinishRegisterAccountInfo")
}
