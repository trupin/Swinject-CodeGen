// this code is autogenerated, do not modify!

import Swinject

extension ResolverType {

    func resolveInjectablePerson(argumentName: ArgumentType, argumenttypewithoutspecificname: ArgumentTypeWithoutSpecificName, title: String, string: String) -> InjectablePerson {
        return self.resolve(PersonType.self, arguments: argumentName, argumenttypewithoutspecificname, title, string) as! InjectablePerson
    }
}

extension Container {

    @discardableResult func registerInjectablePerson(registerClosure: (_ resolver: ResolverType, _ argumentName: ArgumentType, _ argumenttypewithoutspecificname: ArgumentTypeWithoutSpecificName, _ title: String, _ string: String) -> (InjectablePerson)) -> ServiceEntry<PersonType> {
        return self.register(PersonType.self, factory: registerClosure)
    }
}
