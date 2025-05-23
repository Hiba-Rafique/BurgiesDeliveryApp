import java.io.*;
import java.time.LocalDate;
import java.util.*;


class Student implements Serializable {
    private String id;
    private String name;

    public Student(String id, String name) {
        this.id = id;
        this.name = name;
    }

    public String getId() { return id; }
    public String getName() { return name; }

    @Override
    public String toString() {
        return id + " - " + name;
    }
}


class Course implements Serializable {
    private String code;
    private String title;

    public Course(String code, String title) {
        this.code = code;
        this.title = title;
    }

    public String getCode() { return code; }
    public String getTitle() { return title; }

    @Override
    public String toString() {
        return code + ": " + title;
    }
}


class Room implements Serializable {
    private String roomNumber;
    private int capacity;

    public Room(String roomNumber, int capacity) {
        this.roomNumber = roomNumber;
        this.capacity = capacity;
    }

    public String getRoomNumber() { return roomNumber; }
    public int getCapacity() { return capacity; }

    @Override
    public String toString() {
        return roomNumber + " (Capacity: " + capacity + ")";
    }
}


class ExamSlot implements Serializable {
    private LocalDate date;
    private String timeSlot; // "Slot 1", "Slot 2", "Slot 3"
    private Course course;
    private Room room;
    private List<Student> students;

    public ExamSlot(LocalDate date, String timeSlot, Course course, Room room) {
        this.date = date;
        this.timeSlot = timeSlot;
        this.course = course;
        this.room = room;
        this.students = new ArrayList<>();
    }

    public void addStudent(Student student) {
        students.add(student);
    }

    public LocalDate getDate() { return date; }
    public String getTimeSlot() { return timeSlot; }
    public Course getCourse() { return course; }
    public Room getRoom() { return room; }
    public List<Student> getStudents() { return students; }

    @Override
    public String toString() {
        return course.getTitle() + " on " + date + " at " + timeSlot + " in " + room.getRoomNumber();
    }
}


class DateSheetManager implements Serializable {
    private List<Student> students;
    private List<Course> courses;
    private List<Room> rooms;
    private List<ExamSlot> examSlots;

    public DateSheetManager() {
        students = new ArrayList<>();
        courses = new ArrayList<>();
        rooms = new ArrayList<>();
        examSlots = new ArrayList<>();
    }

    public void addStudent(Student student) { students.add(student); }
    public void addCourse(Course course) { courses.add(course); }
    public void addRoom(Room room) { rooms.add(room); }
    public void addExamSlot(ExamSlot slot) { examSlots.add(slot); }
    public void assignStudentToExamSlot(Student student, ExamSlot slot) {
        slot.addStudent(student);
    }

    public List<ExamSlot> getExamSlots() {
        return examSlots;
    }

    public void saveToFile(String filename) {
        try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(filename))) {
            out.writeObject(this);
            System.out.println("DateSheet saved to file.");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static DateSheetManager loadFromFile(String filename) {
        try (ObjectInputStream in = new ObjectInputStream(new FileInputStream(filename))) {
            return (DateSheetManager) in.readObject();
        } catch (IOException | ClassNotFoundException e) {
            System.out.println("Could not load file. Returning empty manager.");
            return new DateSheetManager();
        }
    }
}

public class Main {
    public static void main(String[] args) {
        DateSheetManager manager = new DateSheetManager();

        // Sample data
        Student s1 = new Student("S001", "Ali");
        Student s2 = new Student("S002", "Sara");
        Course c1 = new Course("CS212", "Object Oriented Programming");
        Room r1 = new Room("1", 30);

        manager.addStudent(s1);
        manager.addStudent(s2);
        manager.addCourse(c1);
        manager.addRoom(r1);

        ExamSlot es1 = new ExamSlot(LocalDate.of(2025, 6, 5), "Slot 1", c1, r1);
        manager.addExamSlot(es1);

        manager.assignStudentToExamSlot(s1, es1);
        manager.assignStudentToExamSlot(s2, es1);

        // Save and load
        manager.saveToFile("datesheet.ser");

        DateSheetManager loadedManager = DateSheetManager.loadFromFile("datesheet.ser");
        System.out.println("Restored Exam Slot Students:");
        for (Student s : loadedManager.getExamSlots().get(0).getStudents()) {
            System.out.println(s.getName());
        }
    }
}
