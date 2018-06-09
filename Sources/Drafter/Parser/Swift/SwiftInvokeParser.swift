//
//  SwiftInvokeParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/11/12.
//

import Foundation

class SwiftInvokeParser: ConcreteParserType {
    
    var parser: TokenParser<[MethodInvokeNode]> {
        return methodInvoke.continuous.map({ (methods) -> [MethodInvokeNode] in
            var result = methods
            for method in methods {
                result.append(contentsOf: method.params.reduce([]) { $0 + $1.invokes })
            }
            return result
        })
    }
}

// MARK: - Parser

extension SwiftInvokeParser {
    
    /// method_invoke = single_method ('.' single_method)
    var methodInvoke: TokenParser<MethodInvokeNode> {
        return singleMethod
            .sepBy(token(.dot))
            .flatMap({ (methods) -> TokenParser<MethodInvokeNode> in
                guard methods.count > 0 else {
                    return error()
                }
                return pure(methods.dropFirst().reduce(methods[0]) { (last, current) in
                    current.invoker = .method(last)
                    return current
                })
            })
    }
    
    // FIXME: 尾随闭包
    /// 匹配一个单独的方法调用
    /// single_method = (invoker '.')? NAME '(' param_list? ')'
    var singleMethod: TokenParser<MethodInvokeNode> {
        return curry(MethodInvokeNode.swiftInit)
            <^> token(.name) => stringify // 方法名
            <*> paramList.between(token(.leftParen), token(.rightParen)) // 参数列表
    }
    
    /// 解析一个参数列表, 该parser不会失败
    /**
     param_list = param (param ',')*
     */
    var paramList: TokenParser<[InvokeParam]> {
        // FIXME: 目前没有匹配数字，如 method(2) 这种情况无法正确解析参数个数
        return token(.rightParen).lookahead *> pure([])
            <|> param.sepBy(token(.comma))
    }
    
    /// 解析单个参数，该parser不会失败
    /**
     param =  (NAME ':')? param_body
     */
    var param: TokenParser<InvokeParam> {
        return curry(InvokeParam.init)
            <^> (token(.name) <* token(.colon)).try => stringify
            <*> paramBody.try ?? []
    }
    
    /// 匹配参数体中的的方法调用，没有则为空
    var paramBody: TokenParser<[MethodInvokeNode]> {
        return { lazy(self.singleMethod).continuous.run($0) ?? [] }
            <^> anyOpenTokens(until: token(.rightParen) <|> token(.comma))
    }
}

extension MethodInvokeNode {
    static func swiftInit(methodName: String, _ params: [InvokeParam]) -> MethodInvokeNode {
        let invoke = MethodInvokeNode()
        invoke.isSwift = true
        invoke.params = params
        invoke.methodName = methodName
        return invoke
    }
}
