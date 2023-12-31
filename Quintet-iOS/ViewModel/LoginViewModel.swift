//
//  LoginViewModel.swift
//  Quintet-iOS
//
//  Created by 이동현 on 2023/09/02.
//

import SwiftUI
import GoogleSignIn
import Moya
import AuthenticationServices


class LoginViewModel: ObservableObject{
    @Published var isLoggedIn = false
    
}

// MARK: - apple login
extension LoginViewModel {
    func getAppleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        var fullName = credential.fullName
        var fullNameString: String?
        
        if let firstName = fullName?.givenName {
            if let lastName = fullName?.familyName {
                fullNameString = "\(firstName) \(lastName)"
            } else {
                fullNameString = "\(firstName)"
            }
        } else {
            if let lastName = fullName?.familyName {
                fullNameString = "\(lastName)"
            }
        }
        
        getJWTTokenApple(
            idToken: credential.identityToken,
            name: fullNameString,
            email: credential.email
        ) { response in
            //추후에 로직 추가
        }
    }
    
    func getJWTTokenApple(
        idToken: Data?,
        name: String?,
        email: String?,
        completion: @escaping (String?
        ) -> Void) {
        let provider = MoyaProvider<OAuthAPI>()
        provider.request(.postAppleIdToken(token: idToken, name: name, email: email)) { result in
            print(result)
            switch result{
            case .success(let response):
                if let header = response.response?.allHeaderFields as? [String: String],
                   let authorizationToken = header["Authorization"] {
                    print("Received Authorization header: \(authorizationToken)")
                }
                let decoder = JSONDecoder()
                print(response)
            case .failure(let error):
                print("네트워크 오류: \(error.localizedDescription)")
                print(error.errorCode)
                completion(nil)
            }
        }
    }
}

// MARK: - google login
extension LoginViewModel {
    
    func getGoogleIDToken(completion: @escaping (String?) -> Void){
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completion(nil)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController){ signInResult, err in
            if let error = err{
                print("Google SignIn 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let signInResult = signInResult else{
                completion(nil)
                return
            }
            
            signInResult.user.refreshTokensIfNeeded{ user, error in
                if let error = error{
                    print("Google SignIn 토큰 리프레시 error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let user = user else{
                    completion(nil)
                    return
                }
                
                let idToken = user.idToken?.tokenString
                completion(idToken)
            }
        }
    }
    
    // MARK: - getGoogleIDToken을 이용하여 얻은 idToken을 백엔드 서버에 전달
    func getJWTTokenGoogle(idToken: String, completion: @escaping (String?) -> Void){
        let provider = MoyaProvider<OAuthAPI>()
        provider.request(.postGoogleIdToken(token: idToken)) { result in
            print(result)
            switch result{
            case .success(let response):
                do{
                    if let header = response.response?.allHeaderFields as? [String: String],
                       let authorizationToken = header["Authorization"] {
                        print("Received Authorization header: \(authorizationToken)")
                    }
                    
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(GoogleIdTokenResponse.self, from: response.data)
                    
                    if apiResponse.isSuccess{
                        let jwtToken = apiResponse.result
                        completion(jwtToken)
                    }else {
                        print("id 토큰이 유효하지 않음")
                        completion(nil)
                    }
                }catch{
                    print("JSON 파싱 실패: \(error.localizedDescription)")
                    completion(nil)
                }
            case .failure(let error):
                print("네트워크 오류: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // MARK: - 전체 로그인 과정을 처리
    func googleSignIn() {
        print("구글 로그인 시도 시작")
        getGoogleIDToken{ idToken in
            guard let idToken = idToken else {
                print("Google ID 토큰 얻기 실패")
                return
            }
            
            self.getJWTTokenGoogle(idToken: idToken) { jwtToken in
                guard let jwtToken = jwtToken else {
                    print("JWT 토큰 얻기 실패")
                    return
                }
                print(jwtToken)
            }
        }
        
        // MARK: - 서버 연결 없이 HomeView로 이동하고 싶으면 아래 주석을 해제
//        print("서버 닫힌 상태에서 테스트")
//        isLoggedIn = true
//        UserDefaults.standard.set(1, forKey: "LoginID")
        
        print("구글 로그인 시도 마무리")
    }
}
