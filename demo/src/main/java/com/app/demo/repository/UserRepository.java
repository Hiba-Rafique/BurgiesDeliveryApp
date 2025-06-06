package com.app.demo.repository;

import com.app.demo.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
@Repository
public interface UserRepository extends JpaRepository<User,Long> {

    Optional<User> findByEmail(String email);

    User findByFirstNameAndLastName(String firstName, String lastName);

    Object getUserByEmail(String email);
}
