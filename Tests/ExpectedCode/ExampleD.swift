// this code is autogenerated, do not modify!

import Swinject

extension ResolverType {

    func resolveInjectablePerson(argumentName: ArgumentType) -> InjectablePerson {
        return self.resolve(PersonType.self, argument: argumentName) as! InjectablePerson
    }
}

extension Container {

    @discardableResult func registerInjectablePerson(registerClosure: (_ resolver: ResolverType, _ argumentName: ArgumentType) -> (InjectablePerson)) -> ServiceEntry<PersonType> {
        return self.register(PersonType.self, factory: registerClosure)
    }
}
