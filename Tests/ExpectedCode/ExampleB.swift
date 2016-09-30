// this code is autogenerated, do not modify!

import Swinject

extension ResolverType {

    func resolveInjectablePerson() -> InjectablePerson {
        return self.resolve(PersonType.self) as! InjectablePerson
    }
}

extension Container {

    func registerInjectablePerson(registerClosure: (_ resolver: ResolverType) -> (InjectablePerson)) -> ServiceEntry<PersonType> {
        return self.register(PersonType.self, factory: registerClosure)
    }
}
